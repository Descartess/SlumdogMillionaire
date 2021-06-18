//
//  View+Extensions.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 04/06/2021.
//

import SwiftUI

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        self.opacity(shouldHide ? 0 : 1)
    }

    @ViewBuilder func remove(_ shouldRemove: Bool) -> some View {
        if shouldRemove {
            EmptyView()
        } else {
            self
        }
    }
}
