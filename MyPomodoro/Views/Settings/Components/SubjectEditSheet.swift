//
//  SubjectEditSheet.swift
//  MyPomodoro
//

import SwiftUI

struct SubjectEditSheet: View {
    let title: String
    @Binding var name: String
    @Binding var colorHex: String
    let validationError: String?
    let onSave: () -> Void
    let onCancel: () -> Void

    private let palette = SubjectColorPalette.allCases

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("과목 이름")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("과목 이름을 입력하세요", text: $name)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                        .foregroundStyle(.white)
#if os(iOS) || os(tvOS) || os(visionOS)
                        .textInputAutocapitalization(.never)
#endif
                        .autocorrectionDisabled()
#if os(macOS)
                        .textFieldStyle(.plain)
#endif
                    
                    if let validationError {
                        Text(validationError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 4)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("색상")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(palette) { preset in
                            Button {
                                colorHex = preset.hex
                            } label: {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(hex: preset.hex))
                                    .frame(height: 48)
                                    .overlay {
                                        if colorHex == preset.hex {
                                            Image(systemName: "checkmark")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: onSave)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

private enum SubjectColorPalette: CaseIterable, Identifiable {
    case coral
    case sky
    case mint
    case violet
    case amber
    case rose

    var id: String { hex }

    var hex: String {
        switch self {
        case .coral: return "#FF6B6B"
        case .sky: return "#4D96FF"
        case .mint: return "#2ED3B7"
        case .violet: return "#A66CFF"
        case .amber: return "#FFB74D"
        case .rose: return "#F06292"
        }
    }
}
