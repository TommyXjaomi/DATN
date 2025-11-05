"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import type { SkillType } from "@/types"
import { useTranslations } from '@/lib/i18n'
import { cn } from "@/lib/utils"
import { Headphones, BookOpen, PenTool, Mic, TrendingUp, Award } from "lucide-react"
import React from "react"

interface SkillProgressCardProps {
  skill: SkillType
  currentScore: number
  targetScore: number
  exercisesCompleted: number
}

const skillConfig: Record<SkillType, { 
  label: string
  color: string
  gradient: string
  icon: typeof Headphones
  bgGradient: string
}> = {
  LISTENING: {
    label: "Listening",
    color: "from-blue-500 to-blue-600",
    gradient: "bg-gradient-to-br from-blue-500/10 to-blue-600/5",
    icon: Headphones,
    bgGradient: "bg-gradient-to-br from-blue-500/5 via-blue-500/10 to-transparent"
  },
  READING: {
    label: "Reading",
    color: "from-green-500 to-green-600",
    gradient: "bg-gradient-to-br from-green-500/10 to-green-600/5",
    icon: BookOpen,
    bgGradient: "bg-gradient-to-br from-green-500/5 via-green-500/10 to-transparent"
  },
  WRITING: {
    label: "Writing",
    color: "from-purple-500 to-purple-600",
    gradient: "bg-gradient-to-br from-purple-500/10 to-purple-600/5",
    icon: PenTool,
    bgGradient: "bg-gradient-to-br from-purple-500/5 via-purple-500/10 to-transparent"
  },
  SPEAKING: {
    label: "Speaking",
    color: "from-orange-500 to-orange-600",
    gradient: "bg-gradient-to-br from-orange-500/10 to-orange-600/5",
    icon: Mic,
    bgGradient: "bg-gradient-to-br from-orange-500/5 via-orange-500/10 to-transparent"
  },
}

function SkillProgressCardComponent({ skill, currentScore, targetScore, exercisesCompleted }: SkillProgressCardProps) {
  const t = useTranslations('common')
  const config = skillConfig[skill]
  const SkillIcon = config?.icon || Award
  
  // Ensure valid numbers to prevent NaN
  const validCurrentScore = typeof currentScore === 'number' && !isNaN(currentScore) ? currentScore : 0
  const validTargetScore = typeof targetScore === 'number' && !isNaN(targetScore) ? targetScore : 9
  const validExercisesCompleted = typeof exercisesCompleted === 'number' && !isNaN(exercisesCompleted) ? exercisesCompleted : 0
  
  const progress = validTargetScore > 0 ? Math.min((validCurrentScore / validTargetScore) * 100, 100) : 0
  const isOnTrack = validCurrentScore >= validTargetScore * 0.7
  
  // Translate skill label
  const skillLabelMap: Record<SkillType, string> = {
    LISTENING: t('listening'),
    READING: t('reading'),
    WRITING: t('writing'),
    SPEAKING: t('speaking'),
  }
  const translatedLabel = skillLabelMap[skill] || config?.label || 'Unknown'

  return (
    <Card className={cn(
      "group relative overflow-hidden border-border/40 transition-all duration-300",
      "hover:shadow-lg hover:-translate-y-1 hover:border-border/60"
    )}>
      {/* Background gradient */}
      <div className={cn("absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500", config?.bgGradient)} />
      
      <CardHeader className="pb-4 relative z-10">
        <div className="flex items-center justify-between mb-3">
          <div className={cn("p-2 rounded-lg", config?.gradient)}>
            <SkillIcon className={cn("h-5 w-5 bg-gradient-to-br", config?.color, "bg-clip-text text-transparent")} style={{ WebkitTextFillColor: 'transparent' }} />
          </div>
          <div className="flex items-baseline gap-1">
            <span className={cn("text-3xl font-bold bg-gradient-to-br", config?.color, "bg-clip-text text-transparent")}>
              {validCurrentScore.toFixed(1)}
            </span>
            <span className="text-sm text-muted-foreground font-medium">/ {validTargetScore.toFixed(1)}</span>
          </div>
        </div>
        <CardTitle className="text-base font-semibold">{translatedLabel}</CardTitle>
      </CardHeader>
      
      <CardContent className="space-y-4 relative z-10">
        {/* Progress bar with animation */}
        <div className="space-y-2">
          <div className="flex justify-between items-center text-xs">
            <span className="text-muted-foreground font-medium">{t('progress_to_target')}</span>
            <div className="flex items-center gap-1">
              <TrendingUp className={cn(
                "h-3 w-3",
                isOnTrack ? "text-green-500" : "text-orange-500"
              )} />
              <span className={cn(
                "font-bold",
                isOnTrack ? "text-green-600 dark:text-green-500" : "text-orange-600 dark:text-orange-500"
              )}>
                {progress.toFixed(0)}%
              </span>
            </div>
          </div>
          <div className="relative h-2.5 bg-muted rounded-full overflow-hidden">
            <div
              className={cn(
                "h-full rounded-full bg-gradient-to-r transition-all duration-1000 ease-out relative",
                config?.color,
                "after:absolute after:inset-0 after:bg-gradient-to-r after:from-transparent after:via-white/30 after:to-transparent after:animate-shimmer"
              )}
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Exercise count with badge */}
        <div className="flex items-center justify-between pt-3 border-t border-border/50">
          <span className="text-xs text-muted-foreground">{t('completed')}</span>
          <div className={cn(
            "px-2.5 py-1 rounded-full text-xs font-bold",
            config?.gradient
          )}>
            <span className={cn("bg-gradient-to-br", config?.color, "bg-clip-text text-transparent")}>
              {validExercisesCompleted} {t('exercises')}
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export const SkillProgressCard = React.memo(SkillProgressCardComponent)
