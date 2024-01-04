//
//  GoalsListCell.swift
//  573Goals
//
//  Created by Kinney Kare on 1/3/24.
//

import UIKit

class GoalsListCell: UITableViewCell {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var goalAmountLabel: UILabel!
    @IBOutlet weak var GoalNameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressBar.layer.cornerRadius = 8
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 8
        progressBar.subviews[1].clipsToBounds = true
    }
    
    func updateProgressBar(with percentage: Float) {
        progressBar.setProgress(percentage, animated: true)
        progressPercentageLabel.text = String(format: "%.0f%%", percentage * 100)
        
        // Set progress bar color based on the percentage
        if percentage <= 0.25 {
            progressBar.progressTintColor = .red
        } else if percentage <= 0.5 {
            progressBar.progressTintColor = .orange
        } else if percentage <= 0.75 {
            progressBar.progressTintColor = .yellow
        } else {
            progressBar.progressTintColor = .green
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
