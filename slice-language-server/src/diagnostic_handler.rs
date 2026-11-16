// Copyright (c) ZeroC, Inc.

use crate::slice_project::SliceProject;
use crate::utils::{convert_slice_path_to_uri, span_to_range};
use crate::{notifications, show_popup};

use slicec::diagnostics::{AnnotatedDiagnostic, AnnotatedNote, DiagnosticLevel};
use std::collections::HashMap;
use tower_lsp::lsp_types::{DiagnosticRelatedInformation, DiagnosticSeverity, Location, NumberOrString, Url};
use tower_lsp::Client;

/// Publishes diagnostics for all files in the provided project.
///
/// This function takes a client and a project, generates updated diagnostics,
/// and then publishes these diagnostics to the LSP client.
pub async fn publish_diagnostics_for_project(
    client_handle: &Client,
    diagnostics: Vec<AnnotatedDiagnostic>,
    project: &mut SliceProject,
) {
    // Initialize a map to hold diagnostics grouped by file (URL)
    let mut map = project
        .compilation_data
        .files
        .keys()
        .filter_map(|uri| Some((convert_slice_path_to_uri(uri)?, vec![])))
        .collect::<HashMap<Url, Vec<tower_lsp::lsp_types::Diagnostic>>>();

    // Process the diagnostics and populate the map.
    let spanless_diagnostics = process_diagnostics(diagnostics, &mut map);
    for diagnostic in spanless_diagnostics {
        show_popup(client_handle, diagnostic.message, notifications::MessageType::Error).await;
    }

    // Publish the diagnostics for each file
    for (uri, lsp_diagnostics) in map {
        client_handle.publish_diagnostics(uri, lsp_diagnostics, None).await;
    }
}

/// Processes a list of diagnostics and updates the publish map with LSP-compatible diagnostics.
///
/// Allowed lints are dropped. Any diagnostics that do not have a span are returned for further processing.
pub fn process_diagnostics(
    diagnostics: Vec<AnnotatedDiagnostic>,
    publish_map: &mut HashMap<Url, Vec<tower_lsp::lsp_types::Diagnostic>>,
) -> Vec<AnnotatedDiagnostic> {
    let mut spanless_diagnostics = Vec::new();
    for diagnostic in diagnostics {
        let severity = match diagnostic.level {
            DiagnosticLevel::Error => DiagnosticSeverity::ERROR,
            DiagnosticLevel::Warning => DiagnosticSeverity::WARNING,
            DiagnosticLevel::Info => DiagnosticSeverity::INFORMATION,
            DiagnosticLevel::Allowed => continue,
        };

        let Some(span) = diagnostic.snippet.as_ref().map(|snippet| snippet.span.clone()) else {
            spanless_diagnostics.push(diagnostic);
            continue;
        };
        let Some(uri) = convert_slice_path_to_uri(&span.file) else {
            continue;
        };

        let related_information = diagnostic
            .notes
            .iter()
            .filter_map(try_into_lsp_diagnostic_related_information)
            .collect();

        let lsp_diagnostic = tower_lsp::lsp_types::Diagnostic {
            range: span_to_range(span),
            severity: Some(severity),
            code: Some(NumberOrString::String(diagnostic.code)),
            code_description: None,
            source: Some("slicec".to_owned()),
            message: diagnostic.message,
            related_information: Some(related_information),
            tags: None,
            data: None,
        };
        publish_map.entry(uri).or_default().push(lsp_diagnostic);
    }
    spanless_diagnostics
}

// A helper function that converts a slicec note into an lsp diagnostic related information
fn try_into_lsp_diagnostic_related_information(
    note: &AnnotatedNote,
) -> Option<tower_lsp::lsp_types::DiagnosticRelatedInformation> {
    let span = note.snippet.as_ref()?.span.clone();
    let uri = convert_slice_path_to_uri(&span.file)?;
    let range = span_to_range(span);

    Some(DiagnosticRelatedInformation {
        location: Location { uri, range },
        message: note.message.clone(),
    })
}
