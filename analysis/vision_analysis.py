#!/usr/bin/env python3
"""
Vision Data Analysis for FANUC iRVision CNC Workcell

Analyzes vision log data to assess:
- Detection success rate
- Offset statistics and trends
- Vision score distribution
- Cycle time performance
- Calibration drift detection

Author: Barath Kumar JK
Date: Jan-May 2025
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple
from pathlib import Path
from datetime import datetime, timedelta
import warnings

warnings.filterwarnings('ignore')


@dataclass
class VisionMetrics:
    """Container for vision performance metrics."""
    detection_rate: float
    avg_score: float
    score_std: float
    x_offset_mean: float
    x_offset_std: float
    y_offset_mean: float
    y_offset_std: float
    r_offset_mean: float
    r_offset_std: float
    avg_cycle_time_ms: float
    retry_rate: float
    total_cycles: int


@dataclass
class CalibrationDrift:
    """Calibration drift analysis results."""
    x_drift_rate: float  # mm/day
    y_drift_rate: float  # mm/day
    needs_recalibration: bool
    recommendation: str


class VisionLogAnalyzer:
    """Analyze FANUC iRVision log data."""
    
    def __init__(self, log_path: Optional[str] = None):
        """Initialize analyzer with optional log file path."""
        self.df: Optional[pd.DataFrame] = None
        self.metrics: Optional[VisionMetrics] = None
        
        if log_path:
            self.load_log(log_path)
    
    def load_log(self, log_path: str) -> bool:
        """Load vision log CSV file."""
        try:
            self.df = pd.read_csv(log_path)
            self.df['Timestamp'] = pd.to_datetime(self.df['Timestamp'])
            return True
        except Exception as e:
            print(f"Error loading log: {e}")
            return False
    
    def generate_synthetic_data(self, n_cycles: int = 1000, 
                                 success_rate: float = 0.992,
                                 start_date: str = "2025-01-15") -> None:
        """Generate synthetic vision log data for testing."""
        np.random.seed(42)
        
        start = datetime.strptime(start_date, "%Y-%m-%d")
        timestamps = [start + timedelta(seconds=i*15) for i in range(n_cycles)]
        
        # Generate detection success
        detected = np.random.random(n_cycles) < success_rate
        
        # Generate scores (higher for detected parts)
        scores = np.where(detected,
                         np.clip(np.random.normal(88, 5, n_cycles), 75, 100),
                         np.random.uniform(30, 70, n_cycles))
        
        # Generate offsets (small for good calibration)
        x_offsets = np.random.normal(0.5, 1.5, n_cycles)  # Small positive drift
        y_offsets = np.random.normal(-0.2, 1.2, n_cycles)
        r_offsets = np.random.normal(0.1, 0.5, n_cycles)
        
        # Add calibration drift over time
        drift_factor = np.linspace(0, 1.5, n_cycles)  # 1.5mm drift over period
        x_offsets += drift_factor
        
        # Cycle times
        cycle_times = np.random.normal(12500, 500, n_cycles)  # ~12.5 seconds
        
        # Retries (correlated with low scores)
        retries = (scores < 80).astype(int)
        
        self.df = pd.DataFrame({
            'Timestamp': timestamps,
            'Cycle': range(1, n_cycles + 1),
            'Score': np.round(scores, 1),
            'X_Offset': np.round(x_offsets, 2),
            'Y_Offset': np.round(y_offsets, 2),
            'R_Offset': np.round(r_offsets, 2),
            'Cycle_Time_ms': np.round(cycle_times, 0).astype(int),
            'Retry': retries
        })
    
    def compute_metrics(self) -> VisionMetrics:
        """Compute overall vision performance metrics."""
        if self.df is None:
            raise ValueError("No data loaded")
        
        # Detection rate (score >= 75)
        detected = self.df['Score'] >= 75
        detection_rate = detected.mean() * 100
        
        # Score statistics (only for detected parts)
        detected_scores = self.df.loc[detected, 'Score']
        
        self.metrics = VisionMetrics(
            detection_rate=detection_rate,
            avg_score=detected_scores.mean(),
            score_std=detected_scores.std(),
            x_offset_mean=self.df['X_Offset'].mean(),
            x_offset_std=self.df['X_Offset'].std(),
            y_offset_mean=self.df['Y_Offset'].mean(),
            y_offset_std=self.df['Y_Offset'].std(),
            r_offset_mean=self.df['R_Offset'].mean(),
            r_offset_std=self.df['R_Offset'].std(),
            avg_cycle_time_ms=self.df['Cycle_Time_ms'].mean(),
            retry_rate=self.df['Retry'].mean() * 100,
            total_cycles=len(self.df)
        )
        
        return self.metrics
    
    def analyze_calibration_drift(self, window_days: int = 7) -> CalibrationDrift:
        """Analyze calibration drift over time."""
        if self.df is None:
            raise ValueError("No data loaded")
        
        # Group by day and compute mean offsets
        self.df['Date'] = self.df['Timestamp'].dt.date
        daily_stats = self.df.groupby('Date').agg({
            'X_Offset': 'mean',
            'Y_Offset': 'mean'
        }).reset_index()
        
        if len(daily_stats) < 2:
            return CalibrationDrift(0, 0, False, "Insufficient data")
        
        # Linear fit for drift
        days = np.arange(len(daily_stats))
        x_coef = np.polyfit(days, daily_stats['X_Offset'].values, 1)
        y_coef = np.polyfit(days, daily_stats['Y_Offset'].values, 1)
        
        x_drift_rate = x_coef[0]  # mm/day
        y_drift_rate = y_coef[0]  # mm/day
        
        # Check if recalibration needed
        total_drift = np.sqrt(x_drift_rate**2 + y_drift_rate**2) * window_days
        needs_recal = total_drift > 0.5  # 0.5mm threshold
        
        if needs_recal:
            recommendation = f"Recalibration recommended. Estimated drift: {total_drift:.2f}mm over {window_days} days."
        else:
            recommendation = f"Calibration OK. Drift rate: {total_drift:.3f}mm over {window_days} days."
        
        return CalibrationDrift(
            x_drift_rate=x_drift_rate,
            y_drift_rate=y_drift_rate,
            needs_recalibration=needs_recal,
            recommendation=recommendation
        )
    
    def generate_report(self) -> str:
        """Generate text performance report."""
        if self.metrics is None:
            self.compute_metrics()
        
        m = self.metrics
        drift = self.analyze_calibration_drift()
        
        report = f"""
{'='*70}
FANUC iRVISION PERFORMANCE REPORT
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
{'='*70}

OVERALL PERFORMANCE
{'-'*40}
Total Cycles Analyzed:    {m.total_cycles:,}
Detection Success Rate:   {m.detection_rate:.1f}%
Retry Rate:               {m.retry_rate:.1f}%
Average Cycle Time:       {m.avg_cycle_time_ms/1000:.2f} seconds

VISION SCORE STATISTICS
{'-'*40}
Average Score:            {m.avg_score:.1f}%
Score Std Dev:            {m.score_std:.1f}%
Score Range:              {self.df['Score'].min():.1f}% - {self.df['Score'].max():.1f}%

OFFSET STATISTICS (mm)
{'-'*40}
                          Mean        Std Dev
X Offset:                {m.x_offset_mean:>7.2f}      {m.x_offset_std:>7.2f}
Y Offset:                {m.y_offset_mean:>7.2f}      {m.y_offset_std:>7.2f}
R Offset (deg):          {m.r_offset_mean:>7.2f}      {m.r_offset_std:>7.2f}

CALIBRATION DRIFT ANALYSIS
{'-'*40}
X Drift Rate:             {drift.x_drift_rate:.4f} mm/day
Y Drift Rate:             {drift.y_drift_rate:.4f} mm/day
Status:                   {'⚠️  RECALIBRATION NEEDED' if drift.needs_recalibration else '✓ OK'}
{drift.recommendation}

PRODUCTION METRICS
{'-'*40}
Parts per Hour:           {3600 / (m.avg_cycle_time_ms/1000):.1f}
Estimated Daily Output:   {(3600 / (m.avg_cycle_time_ms/1000)) * 8 * (m.detection_rate/100):.0f} parts (8hr shift)

{'='*70}
"""
        return report
    
    def plot_analysis(self, output_path: Optional[str] = None) -> None:
        """Generate analysis plots."""
        if self.df is None:
            raise ValueError("No data loaded")
        
        fig, axes = plt.subplots(2, 3, figsize=(15, 10))
        fig.suptitle('FANUC iRVision Performance Analysis', fontsize=14, fontweight='bold')
        
        # 1. Vision score distribution
        ax = axes[0, 0]
        ax.hist(self.df['Score'], bins=30, edgecolor='black', alpha=0.7, color='steelblue')
        ax.axvline(75, color='red', linestyle='--', label='Threshold (75%)')
        ax.axvline(self.df['Score'].mean(), color='green', linestyle='-', label=f'Mean ({self.df["Score"].mean():.1f}%)')
        ax.set_xlabel('Vision Score (%)')
        ax.set_ylabel('Frequency')
        ax.set_title('Vision Score Distribution')
        ax.legend()
        
        # 2. X/Y offset scatter
        ax = axes[0, 1]
        ax.scatter(self.df['X_Offset'], self.df['Y_Offset'], alpha=0.3, s=10)
        ax.axhline(0, color='gray', linestyle='-', linewidth=0.5)
        ax.axvline(0, color='gray', linestyle='-', linewidth=0.5)
        # Add tolerance circle
        circle = plt.Circle((0, 0), 5, fill=False, color='red', linestyle='--', label='±5mm tolerance')
        ax.add_patch(circle)
        ax.set_xlim(-10, 10)
        ax.set_ylim(-10, 10)
        ax.set_xlabel('X Offset (mm)')
        ax.set_ylabel('Y Offset (mm)')
        ax.set_title('X-Y Offset Distribution')
        ax.set_aspect('equal')
        ax.legend()
        
        # 3. Offset trend over time
        ax = axes[0, 2]
        self.df['Hour'] = self.df['Timestamp'].dt.floor('H')
        hourly = self.df.groupby('Hour').agg({'X_Offset': 'mean', 'Y_Offset': 'mean'}).reset_index()
        ax.plot(range(len(hourly)), hourly['X_Offset'], 'b-', label='X Offset', linewidth=1)
        ax.plot(range(len(hourly)), hourly['Y_Offset'], 'r-', label='Y Offset', linewidth=1)
        ax.axhline(0, color='gray', linestyle='--', linewidth=0.5)
        ax.set_xlabel('Time (hours)')
        ax.set_ylabel('Mean Offset (mm)')
        ax.set_title('Offset Trend (Calibration Drift)')
        ax.legend()
        
        # 4. Cycle time distribution
        ax = axes[1, 0]
        ax.hist(self.df['Cycle_Time_ms']/1000, bins=30, edgecolor='black', alpha=0.7, color='green')
        ax.axvline(self.df['Cycle_Time_ms'].mean()/1000, color='red', linestyle='-', 
                   label=f'Mean ({self.df["Cycle_Time_ms"].mean()/1000:.2f}s)')
        ax.set_xlabel('Cycle Time (seconds)')
        ax.set_ylabel('Frequency')
        ax.set_title('Cycle Time Distribution')
        ax.legend()
        
        # 5. Score vs Retry correlation
        ax = axes[1, 1]
        retry_scores = self.df[self.df['Retry'] == 1]['Score']
        no_retry_scores = self.df[self.df['Retry'] == 0]['Score']
        ax.hist([no_retry_scores, retry_scores], bins=20, label=['No Retry', 'Retry'], 
                edgecolor='black', alpha=0.7, color=['green', 'red'])
        ax.set_xlabel('Vision Score (%)')
        ax.set_ylabel('Frequency')
        ax.set_title('Score Distribution: Retry vs No Retry')
        ax.legend()
        
        # 6. Running detection rate
        ax = axes[1, 2]
        window = 50
        self.df['Detected'] = (self.df['Score'] >= 75).astype(int)
        self.df['Running_Rate'] = self.df['Detected'].rolling(window=window).mean() * 100
        ax.plot(self.df['Cycle'], self.df['Running_Rate'], 'b-', linewidth=0.8)
        ax.axhline(99, color='green', linestyle='--', label='Target (99%)')
        ax.axhline(95, color='orange', linestyle='--', label='Warning (95%)')
        ax.set_xlabel('Cycle Number')
        ax.set_ylabel('Detection Rate (%)')
        ax.set_title(f'Running Detection Rate ({window}-cycle window)')
        ax.set_ylim([90, 100])
        ax.legend()
        
        plt.tight_layout()
        
        if output_path:
            plt.savefig(output_path, dpi=150, bbox_inches='tight')
            print(f"Plot saved to: {output_path}")
        else:
            plt.show()
        
        plt.close()


def main():
    """Main analysis routine."""
    print("FANUC iRVision Performance Analysis")
    print("="*50)
    
    # Create analyzer
    analyzer = VisionLogAnalyzer()
    
    # Generate synthetic data for demonstration
    print("\nGenerating synthetic vision log data...")
    analyzer.generate_synthetic_data(n_cycles=1000, success_rate=0.992)
    
    # Compute metrics
    print("Computing performance metrics...")
    metrics = analyzer.compute_metrics()
    
    # Generate report
    report = analyzer.generate_report()
    print(report)
    
    # Save report
    output_dir = Path('/tmp/fanuc_vision_analysis')
    output_dir.mkdir(parents=True, exist_ok=True)
    
    report_path = output_dir / f'vision_report_{datetime.now().strftime("%Y%m%d_%H%M%S")}.txt'
    with open(report_path, 'w') as f:
        f.write(report)
    print(f"Report saved to: {report_path}")
    
    # Generate plots
    plot_path = output_dir / f'vision_analysis_{datetime.now().strftime("%Y%m%d_%H%M%S")}.png'
    analyzer.plot_analysis(str(plot_path))
    
    # Save synthetic log for reference
    log_path = output_dir / 'sample_vision_log.csv'
    analyzer.df.to_csv(log_path, index=False)
    print(f"Sample log saved to: {log_path}")
    
    return metrics


if __name__ == '__main__':
    main()
