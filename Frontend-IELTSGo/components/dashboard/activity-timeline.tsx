"use client"

import React, { useMemo, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { BookOpen, FileText, GraduationCap, Clock, Award, TrendingUp } from "lucide-react"
import { formatDistanceToNow } from "date-fns"
import { vi } from "date-fns/locale"
import { useTranslations } from '@/lib/i18n'
import { EmptyState } from "./empty-state"
import { cn } from "@/lib/utils"

interface Activity {
  id: string
  type: "course" | "exercise" | "lesson"
  title: string
  completedAt: string
  duration: number
  score?: number
}

interface ActivityTimelineProps {
  activities: Activity[]
}

const activityConfig = {
  course: {
    icon: GraduationCap,
    label: "Course",
    color: "text-blue-600 dark:text-blue-400",
    bgColor: "bg-blue-500/10 group-hover:bg-blue-500/20",
    borderColor: "border-blue-500/20 group-hover:border-blue-500/30",
    gradient: "from-blue-500/20 to-blue-600/10",
  },
  exercise: {
    icon: FileText,
    label: "Exercise",
    color: "text-green-600 dark:text-green-400",
    bgColor: "bg-green-500/10 group-hover:bg-green-500/20",
    borderColor: "border-green-500/20 group-hover:border-green-500/30",
    gradient: "from-green-500/20 to-green-600/10",
  },
  lesson: {
    icon: BookOpen,
    label: "Lesson",
    color: "text-purple-600 dark:text-purple-400",
    bgColor: "bg-purple-500/10 group-hover:bg-purple-500/20",
    borderColor: "border-purple-500/20 group-hover:border-purple-500/30",
    gradient: "from-purple-500/20 to-purple-600/10",
  },
}

function ActivityTimelineComponent({ activities }: ActivityTimelineProps) {
  const t = useTranslations('common')
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)
  
  // Memoize grouping and sorting to avoid recalculating on every render
  const sorted = useMemo(() => {
    // Group activities by type+title, keep only latest, count attempts
    const grouped: Record<string, { activity: Activity; count: number }> = {}
    activities.forEach((activity) => {
      if (activity.type === "exercise") {
        const key = `${activity.type}-${activity.title}`
        if (!grouped[key] || new Date(activity.completedAt) > new Date(grouped[key].activity.completedAt)) {
          grouped[key] = { activity, count: 1 }
        } else {
          grouped[key].count += 1
        }
      } else {
        // For course/lesson, just show all
        const key = `${activity.type}-${activity.id}`
        if (!grouped[key]) grouped[key] = { activity, count: 1 }
      }
    })
    // Sort by completedAt desc
    return Object.values(grouped).sort((a, b) => new Date(b.activity.completedAt).getTime() - new Date(a.activity.completedAt).getTime())
  }, [activities])
  
  return (
    <Card className="overflow-hidden border-border/40 shadow-sm hover:shadow-md transition-shadow duration-300">
      <CardHeader className="pb-4 border-b border-border/40">
        <CardTitle className="text-lg font-semibold flex items-center gap-2">
          <Clock className="h-5 w-5 text-primary" />
          Hoạt động gần đây
        </CardTitle>
      </CardHeader>
      <CardContent className="pt-4">
        {sorted.length === 0 ? (
          <EmptyState 
            type="activity"
            title={t('no_recent_activity') || "Chưa có hoạt động gần đây"}
            description="Hoàn thành bài học hoặc bài tập đầu tiên để xem hoạt động của bạn"
            actionLabel="Bắt đầu học"
            actionHref="/courses"
          />
        ) : (
          <div className="space-y-1">
            {sorted.map(({ activity, count }, index) => {
              const config = activityConfig[activity.type] || activityConfig.exercise
              const Icon = config.icon
              const isHovered = hoveredIndex === index
              
              return (
                <div 
                  key={activity.id + '-' + activity.completedAt} 
                  className="flex gap-4 group"
                  onMouseEnter={() => setHoveredIndex(index)}
                  onMouseLeave={() => setHoveredIndex(null)}
                >
                  {/* Timeline line with animations */}
                  <div className="flex flex-col items-center relative">
                    <div className={cn(
                      "p-2.5 rounded-xl transition-all duration-300 relative z-10 border-2",
                      config.bgColor,
                      config.borderColor,
                      isHovered && "scale-110 shadow-lg"
                    )}>
                      <Icon className={cn("h-4 w-4 transition-colors duration-300", config.color)} />
                      {/* Ripple effect */}
                      {isHovered && (
                        <div className={cn(
                          "absolute inset-0 rounded-xl animate-ping opacity-75",
                          config.bgColor
                        )} />
                      )}
                    </div>
                    {index < sorted.length - 1 && (
                      <div className="w-0.5 flex-1 bg-gradient-to-b from-border to-transparent mt-2" />
                    )}
                  </div>
                  
                  {/* Activity content with enhanced styling */}
                  <div className="flex-1 pb-6">
                    <div className={cn(
                      "p-4 rounded-xl border transition-all duration-300",
                      "border-border/40 hover:border-border/60",
                      "bg-gradient-to-br from-card to-card/50",
                      isHovered && "shadow-md -translate-y-1"
                    )}>
                      <div className="flex items-start justify-between gap-4">
                        <div className="flex-1 space-y-2">
                          <p className="font-semibold text-sm leading-tight">{activity.title}</p>
                          
                          {/* Activity metadata with icons */}
                          <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-muted-foreground">
                            <span className="flex items-center gap-1">
                              <Icon className={cn("h-3 w-3", config.color)} />
                              {activity.type === 'course' ? 'Khóa học' : activity.type === 'exercise' ? 'Bài tập' : 'Bài học'}
                            </span>
                            <span className="flex items-center gap-1">
                              <Clock className="h-3 w-3" />
                              {activity.duration} phút
                            </span>
                            {activity.score !== undefined && activity.score > 0 && (
                              <span className={cn(
                                "flex items-center gap-1 font-semibold",
                                activity.score >= 7 ? "text-green-600 dark:text-green-500" : 
                                activity.score >= 5 ? "text-orange-600 dark:text-orange-500" : 
                                "text-red-600 dark:text-red-500"
                              )}>
                                <Award className="h-3 w-3" />
                                Điểm: {activity.score.toFixed(1)}
                              </span>
                            )}
                            {activity.type === "exercise" && count > 1 && (
                              <span className="flex items-center gap-1 text-orange-600 dark:text-orange-500 font-medium">
                                <TrendingUp className="h-3 w-3" />
                                Làm lại {count} lần
                              </span>
                            )}
                          </div>
                        </div>
                        
                        {/* Time badge */}
                        <div className={cn(
                          "px-2 py-1 rounded-md text-xs font-medium whitespace-nowrap",
                          "bg-muted/50 text-muted-foreground",
                          "transition-all duration-300",
                          isHovered && "bg-primary/10 text-primary"
                        )}>
                          {formatDistanceToNow(new Date(activity.completedAt), {
                            addSuffix: true,
                            locale: vi,
                          })}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export const ActivityTimeline = React.memo(ActivityTimelineComponent)
