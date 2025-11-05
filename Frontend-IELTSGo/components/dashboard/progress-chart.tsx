"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { useMemo, useState } from "react"
import { EmptyState } from "./empty-state"
import { TrendingUp, TrendingDown, Minus } from "lucide-react"

interface DataPoint {
  date: string
  value: number
}

interface ProgressChartProps {
  title: string
  data: DataPoint[]
  color?: string
  valueLabel?: string
}

function ProgressChartComponent({ title, data, color = "#ED372A", valueLabel = "Value" }: ProgressChartProps) {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)
  
  const { maxValue, avgValue, trend } = useMemo(() => {
    if (!data || data.length === 0) return { maxValue: 100, avgValue: 0, trend: 0 }
    const values = data.map((d) => d.value).filter(v => typeof v === 'number' && !isNaN(v))
    if (values.length === 0) return { maxValue: 100, avgValue: 0, trend: 0 }
    
    const max = Math.max(...values, 1)
    const avg = values.reduce((a, b) => a + b, 0) / values.length
    
    // Calculate trend (compare first half vs second half)
    const midPoint = Math.floor(values.length / 2)
    const firstHalf = values.slice(0, midPoint).reduce((a, b) => a + b, 0) / midPoint
    const secondHalf = values.slice(midPoint).reduce((a, b) => a + b, 0) / (values.length - midPoint)
    const trendValue = secondHalf - firstHalf
    
    return { maxValue: max, avgValue: avg, trend: trendValue }
  }, [data])

  const chartHeight = 240
  const minBarHeight = 8
  
  // Ensure data is valid
  const validData = data?.filter(d => d && typeof d.value === 'number' && !isNaN(d.value)) || []
  const hasData = validData.length > 0

  // Generate grid lines
  const gridLines = [0, 0.25, 0.5, 0.75, 1].map(ratio => ({
    y: chartHeight * (1 - ratio),
    value: Math.round(maxValue * ratio)
  }))

  return (
    <Card className="overflow-hidden border-border/40 shadow-sm hover:shadow-md transition-shadow duration-300">
      <CardHeader className="pb-4 space-y-2">
        <div className="flex items-start justify-between">
          <div className="space-y-1">
            <CardTitle className="text-lg font-semibold">{title}</CardTitle>
            <div className="flex items-center gap-4 text-sm">
              <span className="text-muted-foreground">
                Trung bình: <span className="font-medium text-foreground">{avgValue.toFixed(1)} {valueLabel}</span>
              </span>
              {trend !== 0 && (
                <div className={`flex items-center gap-1 ${trend > 0 ? 'text-green-600 dark:text-green-500' : trend < 0 ? 'text-red-600 dark:text-red-500' : 'text-gray-600'}`}>
                  {trend > 0 ? (
                    <TrendingUp className="h-3.5 w-3.5" />
                  ) : trend < 0 ? (
                    <TrendingDown className="h-3.5 w-3.5" />
                  ) : (
                    <Minus className="h-3.5 w-3.5" />
                  )}
                  <span className="text-xs font-medium">
                    {trend > 0 ? '+' : ''}{trend.toFixed(1)}
                  </span>
                </div>
              )}
            </div>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        {!hasData ? (
          <EmptyState 
            type="chart"
            title="Chưa có dữ liệu học tập"
            description="Bắt đầu học để xem biểu đồ tiến độ của bạn theo thời gian"
            actionLabel="Khám phá khóa học"
            actionHref="/courses"
          />
        ) : (
        <div className="relative" style={{ height: chartHeight + 40 }}>
          {/* Grid lines */}
          <div className="absolute left-12 right-0 top-0" style={{ height: chartHeight }}>
            {gridLines.map((line, i) => (
              <div
                key={i}
                className="absolute left-0 right-0 border-t border-dashed border-border/30"
                style={{ top: line.y }}
              />
            ))}
          </div>

          {/* Y-axis labels */}
          <div className="absolute left-0 top-0 flex flex-col justify-between text-xs font-medium text-muted-foreground pr-3" style={{ height: chartHeight }}>
            {gridLines.reverse().map((line, i) => (
              <span key={i} className="leading-none">{line.value}</span>
            ))}
          </div>

          {/* Chart area */}
          <div className="ml-12 flex items-end justify-between gap-[2px] px-1" style={{ height: chartHeight }}>
            {validData.map((point, index) => {
              const heightPx = (point.value / maxValue) * (chartHeight - 20)
              const displayHeightPx = point.value > 0 ? Math.max(heightPx, minBarHeight) : 0
              const isHovered = hoveredIndex === index
              const isSmallValue = heightPx < minBarHeight && point.value > 0
              
              return (
                <div 
                  key={index} 
                  className="flex-1 flex items-end justify-center group relative"
                  onMouseEnter={() => setHoveredIndex(index)}
                  onMouseLeave={() => setHoveredIndex(null)}
                >
                  {/* Bar with gradient */}
                  <div
                    className="w-full rounded-t-md transition-all duration-300 cursor-pointer relative overflow-hidden"
                    style={{
                      height: `${displayHeightPx}px`,
                      background: isHovered 
                        ? `linear-gradient(180deg, ${color} 0%, ${color}dd 100%)`
                        : `linear-gradient(180deg, ${color}ee 0%, ${color}88 100%)`,
                      transform: isHovered ? 'scaleY(1.05)' : 'scaleY(1)',
                      transformOrigin: 'bottom',
                      boxShadow: isHovered ? `0 -4px 12px ${color}40` : 'none',
                    }}
                  >
                    {/* Shine effect on hover */}
                    <div 
                      className="absolute inset-0 bg-gradient-to-t from-transparent via-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                      style={{ transform: 'translateY(-100%)' }}
                    />
                    
                    {/* Enhanced Tooltip */}
                    <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-3 opacity-0 group-hover:opacity-100 transition-all duration-200 pointer-events-none z-20">
                      <div className="bg-gray-900 dark:bg-gray-800 text-white px-3 py-2 rounded-lg shadow-lg border border-white/10">
                        <div className="text-sm font-bold mb-1">
                          {point.value} {valueLabel}
                        </div>
                        <div className="text-xs text-gray-300 whitespace-nowrap">
                          {new Date(point.date).toLocaleDateString("vi-VN", {
                            weekday: "short",
                            month: "short",
                            day: "numeric",
                          })}
                        </div>
                        {/* Arrow pointer */}
                        <div className="absolute top-full left-1/2 -translate-x-1/2 -mt-[1px]">
                          <div className="border-4 border-transparent border-t-gray-900 dark:border-t-gray-800" />
                        </div>
                      </div>
                    </div>
                    
                    {/* Indicator for very small values */}
                    {isSmallValue && (
                      <div className="absolute -top-4 left-1/2 -translate-x-1/2 text-[10px] font-medium text-muted-foreground animate-bounce">
                        ↓
                      </div>
                    )}
                  </div>
                </div>
              )
            })}
          </div>

          {/* X-axis with more labels */}
          <div className="ml-12 mt-3 flex justify-between text-xs font-medium text-muted-foreground px-1">
            {validData.length > 0 && (
              <>
                <span className="flex flex-col items-start">
                  <span className="text-[10px] text-muted-foreground/70">
                    {new Date(validData[0].date).toLocaleDateString("vi-VN", { weekday: "short" })}
                  </span>
                  <span>
                    {new Date(validData[0].date).toLocaleDateString("vi-VN", {
                      month: "short",
                      day: "numeric",
                    })}
                  </span>
                </span>
                {validData.length > 2 && (
                  <span className="flex flex-col items-center opacity-60">
                    <span className="text-[10px] text-muted-foreground/70">
                      {new Date(validData[Math.floor(validData.length / 2)].date).toLocaleDateString("vi-VN", { weekday: "short" })}
                    </span>
                    <span>
                      {new Date(validData[Math.floor(validData.length / 2)].date).toLocaleDateString("vi-VN", {
                        month: "short",
                        day: "numeric",
                      })}
                    </span>
                  </span>
                )}
                <span className="flex flex-col items-end">
                  <span className="text-[10px] text-muted-foreground/70">
                    {new Date(validData[validData.length - 1].date).toLocaleDateString("vi-VN", { weekday: "short" })}
                  </span>
                  <span>
                    {new Date(validData[validData.length - 1].date).toLocaleDateString("vi-VN", {
                      month: "short",
                      day: "numeric",
                    })}
                  </span>
                </span>
              </>
            )}
          </div>
        </div>
        )}
      </CardContent>
    </Card>
  )
}

export const ProgressChart = React.memo(ProgressChartComponent)
