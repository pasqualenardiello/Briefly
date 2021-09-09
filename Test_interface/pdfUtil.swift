//
//  pdfUtil.swift
//  Test_interface
//
//  Created by Pasquale Rendina on 15/07/21.
//

import PDFKit

enum pagesEnum {
    case all
    case first
    case last
}

class pdfUtil{
    
    static func readPDF(url:URL)->String{
        if let pdfText=PDFDocument(url: url)?.string{
            return pdfText
        } else {
            return "Error in file opening"
        }
    }
    static func readPDFpages(url:URL, pages :pagesEnum) -> String{
        if let pdfDocument=PDFDocument(url: url){
            //let pdfText=NSMutableAttributedString()
            var pdfText : String = ""
            switch pages {
            case .all:
                let pdfPages = pdfDocument.pageCount
                for i in 0 ..< pdfPages {
                    guard let page = pdfDocument.page(at: i) else{ return "Error while extracting pdf page text" }
                    guard let pageContent = page.string else { return "Error while extracting pdf page text" }
                    pdfText += pageContent
                }
                return pdfText
            case .first:
                let pdfPages = 0
                guard let page = pdfDocument.page(at: pdfPages) else{ return "Error while extracting pdf page text" }
                guard let pageContent = page.string else { return "Error while extracting pdf page text" }
                pdfText += pageContent
                return pdfText
            case .last:
                let pdfPages = pdfDocument.pageCount-1
                guard let page = pdfDocument.page(at: pdfPages) else{ return "Error while extracting pdf page text" }
                guard let pageContent = page.string else { return "Error while extracting pdf page text" }
                pdfText += pageContent
                return pdfText
            }
        } else {
            return "Error while extracting pdf page text"
        }
    }
    static func imagePDF(url:URL,ofPageNum:Int,width:Int,height:Int)->UIImage{
        guard let image:UIImage=PDFDocument(url: url)?.page(at:ofPageNum)?.thumbnail(of: CGSize(width: width, height: height), for: .mediaBox) else{
            return UIImage()
        }
        return image
    }
    static func imagePDF(url:URL,ofPageNum:Int,cgSize:CGSize)->UIImage{
        guard let image:UIImage=PDFDocument(url: url)?.page(at: ofPageNum)?.thumbnail(of: cgSize, for: .artBox) else {
            return UIImage()
        }
        return image
    }
    static func imagePDF(url:URL,ofPage:pagesEnum,cgSize:CGSize)->UIImage{
        if let pdfDocument=PDFDocument(url: url){
            switch ofPage {
            case .first:
                let pdfPage=0
                guard let image:UIImage=pdfDocument.page(at: pdfPage)?.thumbnail(of: cgSize, for: .artBox) else {
                    return UIImage()
                }
                return image;
            case .last:
                let pdfPage=pdfDocument.pageCount-1
                guard let image:UIImage=pdfDocument.page(at: pdfPage)?.thumbnail(of: cgSize, for: .artBox) else {
                    return UIImage()
                }
                return image;
            default:
                return UIImage()
            }
        }else{
            return UIImage()
        }
    }
    static func imagePDF(url:URL,ofPage:pagesEnum,width:Int,height:Int)->UIImage{
        if let pdfDocument=PDFDocument(url: url){
            switch ofPage {
            case .first:
                let pdfPage=0;
                guard let image:UIImage=pdfDocument.page(at: pdfPage)?.thumbnail(of: CGSize(width: width, height: height), for: .artBox) else {
                    return UIImage()
                }
                return image
            case .last:
                let pdfPage=pdfDocument.pageCount-1
                guard let image:UIImage=pdfDocument.page(at: pdfPage)?.thumbnail(of: CGSize(width: width, height: height), for: .artBox) else{
                    return UIImage()
                }
                return image
            default:
                return UIImage();
            }
        } else {
            return UIImage();
        }
    }
    static func textToPDF(textContent:String,fileName:String)->URL?{
        let printFormatter=UISimpleTextPrintFormatter(text: textContent)
        let renderer=UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        let pageSize=CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let printSize=CGRect(x: 35, y: 35, width: 555.2, height: 801.8)
        renderer.setValue(pageSize, forKey: "paperRect")
        renderer.setValue(printSize, forKey: "printableRect")
        let pdfData=NSMutableData()
        let pdfMetaData = [kCGPDFContextCreator: "Briefly",
                           kCGPDFContextAuthor: UIDevice.current.name,
                           kCGPDFContextTitle: fileName]
        UIGraphicsBeginPDFContextToData(pdfData, .zero, pdfMetaData)
        for i in 0..<renderer.numberOfPages{
            UIGraphicsBeginPDFPage();
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext();
        guard let outputPDFUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Briefly").appendingPathComponent(fileName).appendingPathExtension("pdf")
                else { print("Destination URL not created")
            return nil
        }
        pdfData.write(to: outputPDFUrl, atomically: true)
        return outputPDFUrl
    }
    static func textToPDF(textContent:String,fileName:String,url:URL)->URL?{
        let printFormatter=UISimpleTextPrintFormatter(text: textContent)
        let renderer=UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        let pageSize=CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let printSize=CGRect(x: 35, y: 35, width: 555.2, height: 801.8)
        renderer.setValue(pageSize, forKey: "paperRect")
        renderer.setValue(printSize, forKey: "printableRect")
        let pdfData=NSMutableData()
        let pdfMetaData = [kCGPDFContextCreator: "Briefly",
                           kCGPDFContextAuthor: UIDevice.current.name,
                           kCGPDFContextTitle: fileName]
        UIGraphicsBeginPDFContextToData(pdfData, .zero, pdfMetaData)
        for i in 0..<renderer.numberOfPages{
            UIGraphicsBeginPDFPage();
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext();
        pdfData.write(to: url, atomically: true)
        return url
    }
    static func textToPDF(textContent:String,fileName:String,pageMarginx:Double,pageMarginy:Double)->URL?{
        let printFormatter=UISimpleTextPrintFormatter(text: textContent)
        let renderer=UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        let pageSize=CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        let printSize=CGRect(x: pageMarginx, y: pageMarginy, width: 595.2-pageMarginx, height: 841.8-pageMarginy)
        renderer.setValue(pageSize, forKey: "paperRect")
        renderer.setValue(printSize, forKey: "printableRect")
        let pdfData=NSMutableData()
        let pdfMetaData = [kCGPDFContextCreator: "Briefly",
                           kCGPDFContextAuthor: UIDevice.current.name,
                           kCGPDFContextTitle: fileName]
        UIGraphicsBeginPDFContextToData(pdfData, .zero, pdfMetaData)
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage();
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        guard let outputPDFUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Briefly").appendingPathComponent(fileName).appendingPathExtension("pdf")
                else { print("Destination URL not created")
            return nil
        }
        pdfData.write(to: outputPDFUrl, atomically: true)
        return outputPDFUrl;
    }
}
