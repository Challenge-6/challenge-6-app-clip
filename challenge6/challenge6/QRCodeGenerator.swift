//
//  QRCodeGenerator.swift
//  challenge6
//
//  Created by Gabriel Groppo on 29/10/26.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {

    private let context = CIContext()

    func gerarQRCode(
        texto: String,
        branco: Bool = false
    ) -> UIImage? {

        let gerador = CIFilter.qrCodeGenerator()
        gerador.message = Data(texto.utf8)
        gerador.correctionLevel = "H"

        guard let qrOriginal = gerador.outputImage else {
            return nil
        }

        let imagemFinal: CIImage

        if branco {
            let filtro = CIFilter.falseColor()
            filtro.inputImage = qrOriginal

            filtro.color0 = CIColor(color: .white)

            filtro.color1 = CIColor(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0
            )

            imagemFinal = filtro.outputImage ?? qrOriginal
        } else {
            imagemFinal = qrOriginal
        }

        let imagemAmpliada = imagemFinal.transformed(
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
