"use client"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Trophy, Award, Star } from "lucide-react"
import { type Achievement } from "@/lib/api/achievements"
import { useTranslations } from "@/lib/i18n"
import { cn } from "@/lib/utils"

interface AchievementCardProps {
  achievement: Achievement
  earned: boolean
  earnedAt?: string
}

export function AchievementCard({ achievement, earned, earnedAt }: AchievementCardProps) {
  const t = useTranslations('achievements')

  const getBadgeColor = () => {
    if (achievement.badge_color) {
      return achievement.badge_color
    }
    // Default colors based on points
    if (achievement.points >= 100) return '#FFD700' // Gold
    if (achievement.points >= 50) return '#C0C0C0' // Silver
    if (achievement.points >= 20) return '#CD7F32' // Bronze
    return '#6B7280' // Gray
  }

  const formatCriteria = () => {
    const type = achievement.criteria_type
    const value = achievement.criteria_value
    
    // If no type, return default message
    if (!type || type === 'unknown') {
      return t('criteria_default', { type: 'unknown', value: value || 0 })
    }
    
    // Ensure value is a number
    const numValue = typeof value === 'number' ? value : parseInt(String(value || 0), 10)
    
    // Map criteria types to translation keys (case-insensitive)
    const typeLower = String(type).toLowerCase().trim()
    const criteriaMap: Record<string, string> = {
      // Exercise/Course completion
      'exercises_completed': 'criteria_complete_exercises',
      'courses_completed': 'criteria_complete_courses',
      'complete_exercises': 'criteria_complete_exercises',
      'complete_courses': 'criteria_complete_courses',
      'exercises': 'criteria_complete_exercises',
      'courses': 'criteria_complete_courses',
      'completion': 'criteria_completion', // Generic completion (lessons, exercises, etc.)
      // Study time
      'study_time': 'criteria_study_time',
      'time': 'criteria_study_time',
      // Streak
      'streak': 'criteria_streak',
      // Score
      'score': 'criteria_score',
    }
    
    const translationKey = criteriaMap[typeLower] || 'criteria_default'
    
    // Return translated string with value
    if (translationKey === 'criteria_default') {
      // For default, show type and value (human-readable)
      const typeLabel = type ? String(type).replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()) : 'Unknown'
      return t(translationKey, { type: typeLabel, value: numValue })
    }
    
    return t(translationKey, { value: numValue })
  }

  return (
    <Card className={cn(
      "relative overflow-hidden transition-all duration-200 hover:shadow-md group",
      earned 
        ? "border-primary/30 shadow-sm bg-gradient-to-br from-primary/5 via-background to-background" 
        : "border-border opacity-70 hover:opacity-85"
    )}>
      {/* Top accent bar */}
      <div 
        className={cn(
          "absolute top-0 left-0 right-0 h-1 transition-all",
          earned && "shadow-sm"
        )}
        style={{ backgroundColor: earned ? getBadgeColor() : 'transparent' }}
      />
      
      {/* Icon background circle */}
      <div className="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-gradient-to-br from-primary/10 to-transparent opacity-50" />
      
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between gap-3">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2.5 mb-2">
              <div className={cn(
                "flex items-center justify-center h-10 w-10 rounded-lg transition-all",
                earned 
                  ? "bg-gradient-to-br from-yellow-400 to-yellow-600 shadow-md" 
                  : "bg-muted/50"
              )}>
                {earned ? (
                  <Trophy className="h-5 w-5 text-white" />
                ) : (
                  <Award className="h-5 w-5 text-muted-foreground" />
                )}
              </div>
              <CardTitle className="text-base font-semibold leading-tight">
                {achievement.name}
              </CardTitle>
            </div>
            {achievement.description && (
              <CardDescription className="text-sm line-clamp-2">
                {achievement.description}
              </CardDescription>
            )}
          </div>
        </div>
      </CardHeader>
      
      <CardContent className="space-y-3 pt-0">
        {/* Points and Status */}
        <div className="flex items-center gap-2">
          <Badge 
            variant="secondary" 
            className="flex items-center gap-1.5 px-2.5 py-1 font-medium"
          >
            <Star className="h-3.5 w-3.5 fill-current" />
            <span className="text-xs">{achievement.points} {t('points')}</span>
          </Badge>
          {earned && (
            <Badge 
              variant="default"
              className="px-2.5 py-1 text-xs font-medium"
            >
              {t('earned')}
            </Badge>
          )}
        </div>

        {/* Criteria */}
        <div className="px-3 py-2 bg-muted/40 rounded-md border border-border/50">
          <p className="text-xs text-muted-foreground">
            <span className="font-semibold text-foreground">{t('criteria')}:</span>
            <br />
            <span className="mt-0.5 inline-block">{formatCriteria()}</span>
          </p>
        </div>

        {/* Earned date or locked message */}
        {earned && earnedAt ? (
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            <div className="h-1 w-1 rounded-full bg-primary" />
            <span>{t('earned_at')}: {new Date(earnedAt).toLocaleDateString()}</span>
          </div>
        ) : !earned && (
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground italic">
            <div className="h-1 w-1 rounded-full bg-muted-foreground/50" />
            <span>{t('locked_continue_learning')}</span>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

