"use client"

import React from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { LucideIcon } from "lucide-react"
import { cn } from "@/lib/utils"
import { useTranslations } from '@/lib/i18n'

interface StatCardProps {
  title: string
  value: string | number
  description?: string
  icon: LucideIcon
  trend?: {
    value: number
    isPositive: boolean
  }
  className?: string
}

function StatCardComponent({ title, value, description, icon: Icon, trend, className }: StatCardProps) {
  const t = useTranslations('common')
  return (
    <Card className={cn(
      "group relative overflow-hidden border-border/40 transition-all duration-300",
      "hover:shadow-lg hover:border-primary/30 hover:-translate-y-1 bg-card",
      "before:absolute before:inset-0 before:bg-gradient-to-br before:from-primary/5 before:to-transparent before:opacity-0 hover:before:opacity-100 before:transition-opacity before:duration-300",
      className
    )}>
      {/* Animated gradient border effect */}
      <div className="absolute inset-0 bg-gradient-to-br from-primary/20 via-transparent to-primary/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500 -z-10" />
      
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3 relative z-10">
        <CardTitle className="text-xs font-semibold text-muted-foreground uppercase tracking-wider">{title}</CardTitle>
        <div className="p-2 rounded-lg bg-gradient-to-br from-primary/10 to-primary/5 group-hover:from-primary/20 group-hover:to-primary/10 transition-all duration-300 group-hover:scale-110">
          <Icon className="h-4 w-4 text-primary transition-transform duration-300 group-hover:scale-110" />
        </div>
      </CardHeader>
      <CardContent className="pt-0 relative z-10">
        <div className="text-3xl font-bold tracking-tight mb-2 bg-gradient-to-br from-foreground to-foreground/70 bg-clip-text">
          {value}
        </div>
        {description && (
          <p className="text-xs text-muted-foreground leading-relaxed">{description}</p>
        )}
        {trend && (
          <div className="flex items-center gap-2 mt-3 pt-3 border-t border-border/50">
            <div className={cn(
              "flex items-center gap-1 px-2 py-1 rounded-full text-xs font-bold transition-all duration-300",
              trend.isPositive 
                ? "bg-green-500/10 text-green-600 dark:text-green-500 group-hover:bg-green-500/20" 
                : "bg-red-500/10 text-red-600 dark:text-red-500 group-hover:bg-red-500/20"
            )}>
              <span className="text-sm">{trend.isPositive ? "↑" : "↓"}</span>
              <span>{trend.isPositive ? "+" : ""}{trend.value}%</span>
            </div>
            <span className="text-[10px] text-muted-foreground font-medium">{t('from_last_period')}</span>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export const StatCard = React.memo(StatCardComponent)
