//
//  ToastView.swift
//  MyPomodoro
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.callout)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.black.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
