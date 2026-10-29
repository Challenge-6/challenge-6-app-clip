//
//  QRCodeGenerator.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    func gerarQRCode(texto: String) -> UIImage? {

        let data = Data(texto.utf8)

        filter.message = data
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let imagemAmpliada = outputImage.transformed(
            by: CGAffineTransform(scaleX: 10, y: 10)
        )

        guard let cgImage = context.createCGImage(
            imagemAmpliada,
            from: imagemAmpliada.extent
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
