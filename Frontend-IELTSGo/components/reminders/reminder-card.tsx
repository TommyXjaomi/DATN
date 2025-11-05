"use client"

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Edit, Trash2, ToggleLeft, ToggleRight, Clock } from "lucide-react"
import { type StudyReminder } from "@/lib/api/reminders"
import { useTranslations } from "@/lib/i18n"
import { EditReminderDialog } from "./edit-reminder-dialog"
import { useState } from "react"

interface ReminderCardProps {
  reminder: StudyReminder
  onDelete: (id: string) => void
  onToggle: (id: string) => void
  onUpdate: () => void
}

export function ReminderCard({ reminder, onDelete, onToggle, onUpdate }: ReminderCardProps) {
  const t = useTranslations('reminders')
  const [editDialogOpen, setEditDialogOpen] = useState(false)

  const parseDaysOfWeek = (daysJson?: string): number[] => {
    if (!daysJson) return []
    try {
      return JSON.parse(daysJson)
    } catch {
      return []
    }
  }

  const tCommon = useTranslations('common')
  
  const dayNames = [
    tCommon('sunday_short'),
    tCommon('monday_short'),
    tCommon('tuesday_short'),
    tCommon('wednesday_short'),
    tCommon('thursday_short'),
    tCommon('friday_short'),
    tCommon('saturday_short'),
  ]
  const days = parseDaysOfWeek(reminder.days_of_week)
  
  // Parse time from either "HH:MM:SS" or "YYYY-MM-DDTHH:MM:SS" format
  const formatTime = (timeStr: string): string => {
    if (!timeStr) return '00:00'
    
    // If it's a full datetime string, extract the time part
    if (timeStr.includes('T')) {
      const timePart = timeStr.split('T')[1]
      return timePart.split(':').slice(0, 2).join(':')
    }
    
    // Otherwise, just take HH:MM from the time string
    return timeStr.split(':').slice(0, 2).join(':')
  }
  
  const time = formatTime(reminder.reminder_time)

  return (
    <>
      <Card className={`relative overflow-hidden transition-all duration-200 hover:shadow-md ${
        reminder.is_active 
          ? 'border-primary/20 shadow-sm' 
          : 'border-border opacity-70'
      }`}>
        <CardHeader className="pb-4">
          <div className="flex items-start justify-between gap-3">
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2.5 mb-1.5">
                <div className={`h-2 w-2 rounded-full shrink-0 ${
                  reminder.is_active ? 'bg-primary animate-pulse' : 'bg-muted-foreground/40'
                }`} />
                <CardTitle className="text-base font-semibold truncate">
                  {reminder.title}
                </CardTitle>
              </div>
              {reminder.message && (
                <CardDescription className="text-sm line-clamp-2 mt-1 ml-4">
                  {reminder.message}
                </CardDescription>
              )}
            </div>
            <Badge 
              variant={reminder.is_active ? "default" : "secondary"}
              className="shrink-0 text-xs font-medium px-2.5 py-0.5"
            >
              {reminder.is_active ? t('active') : t('inactive')}
            </Badge>
          </div>
        </CardHeader>
        
        <CardContent className="space-y-3 pt-0">
          {/* Time and Type Info */}
          <div className="flex items-center gap-3 px-3 py-2.5 bg-muted/40 rounded-md border border-border/50">
            <div className="flex items-center gap-2">
              <Clock className="h-4 w-4 text-muted-foreground" />
              <span className="text-sm font-semibold">{time}</span>
            </div>
            <div className="h-4 w-px bg-border/60" />
            <span className="text-sm text-muted-foreground capitalize">
              {t(reminder.reminder_type === 'daily' ? 'daily' : reminder.reminder_type === 'weekly' ? 'weekly' : 'custom')}
            </span>
          </div>
          
          {/* Days of Week - for weekly reminders */}
          {reminder.reminder_type === 'weekly' && days.length > 0 && (
            <div className="flex flex-wrap gap-1.5">
              {days.map((day) => (
                <Badge 
                  key={day} 
                  variant="outline" 
                  className="text-xs font-medium px-2.5 py-0.5"
                >
                  {dayNames[day]}
                </Badge>
              ))}
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex items-center gap-2 pt-2">
            <Button
              variant={reminder.is_active ? "default" : "outline"}
              size="sm"
              onClick={() => onToggle(reminder.id)}
              className="flex-1"
            >
              {reminder.is_active ? (
                <>
                  <ToggleRight className="h-4 w-4 mr-1.5" />
                  <span className="text-sm">{t('turn_off')}</span>
                </>
              ) : (
                <>
                  <ToggleLeft className="h-4 w-4 mr-1.5" />
                  <span className="text-sm">{t('turn_on')}</span>
                </>
              )}
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setEditDialogOpen(true)}
              className="shrink-0 h-9 w-9 p-0"
            >
              <Edit className="h-4 w-4" />
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onDelete(reminder.id)}
              className="shrink-0 h-9 w-9 p-0 hover:bg-destructive/10 hover:text-destructive"
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        </CardContent>
      </Card>

      <EditReminderDialog
        open={editDialogOpen}
        onOpenChange={setEditDialogOpen}
        reminder={reminder}
        onSuccess={onUpdate}
      />
    </>
  )
}

