//
//  ChartViewController.swift
//  BetMe
//
//  Created by Rich Henry on 14/06/2017.
//  Copyright © 2017 Easysoft Ltd. All rights reserved.
//

import UIKit
import Charts

// https://medium.com/@skoli/using-realm-and-charts-with-swift-3-in-ios-10-40c42e3838c0

private extension ClosedRange where Bound : FloatingPoint {

    func random() -> Bound {

        let range = self.upperBound - self.lowerBound
        let randomValue = (Bound(arc4random_uniform(UINT32_MAX)) / Bound(UINT32_MAX)) * range + self.lowerBound

        return randomValue
    }
}

class ChartViewController: UIViewController {

    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    
    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var entries: [CandleChartDataEntry] = []

        for i in 0...50 {

            let x = Double(i) * 1.2
            let o = (-1.0...1.0).random()
            let c = (-1.0...1.0).random()
            let h = max(o, c) + (0.1...1.0).random()
            let l = min(o, c) - (0.1...1.0).random()

            entries.append(CandleChartDataEntry(x: x, shadowH: h, shadowL: l, open: o, close: c))
        }

        let dataSet: CandleChartDataSet = CandleChartDataSet(values: entries, label: "Candlestick Maker")
        
        candleStickChartView.data = CandleChartData(dataSet: dataSet)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
