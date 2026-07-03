//
//  SubjectDistributionChart.swift
//  MyPomodoro
//

import Foundation
import SwiftUI

struct SubjectDistributionChart: View {
    let items: [SubjectDistributionItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("과목 분포")
                .font(.headline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(hex: item.colorHex))
                                .frame(width: 10, height: 10)

                            Text(item.name)
                                .foregroundStyle(.white)

                            Spacer()

                            Text("\(item.minutes)분")
                                .foregroundStyle(.secondary)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 8)

                                Capsule()
                                    .fill(Color(hex: item.colorHex))
                                    .frame(
                                        width: max(geometry.size.width * min(item.percentage / 100, 1), 6),
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)

                        Text(String(format: "%.0f%%", item.percentage))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
                }
            }
        }
    }
}
