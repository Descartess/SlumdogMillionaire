//
//  View+Extensions.swift
//  SlumDogMillionaire
//
//  Created by Paul Nyondo on 04/06/2021.
//

import SwiftUI

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide { hidden() } else { self }
    }
}
