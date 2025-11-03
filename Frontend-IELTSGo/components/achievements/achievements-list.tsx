"use client"

import { useState, useEffect, useMemo, lazy, Suspense } from "react"
import { achievementsApi, type Achievement, type UserAchievement } from "@/lib/api/achievements"
import { useToast } from "@/hooks/use-toast"
import { useTranslations } from "@/lib/i18n"
import { PageLoading } from "@/components/ui/page-loading"
import { EmptyState } from "@/components/ui/empty-state"
import { Award, Trophy } from "lucide-react"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

// Lazy load AchievementCard to improve initial load time
const AchievementCard = lazy(() => import("./achievement-card").then(m => ({ default: m.AchievementCard })))

export function AchievementsList() {
  const t = useTranslations('achievements')
  const tCommon = useTranslations('common')
  const { toast } = useToast()
  const [allAchievements, setAllAchievements] = useState<Achievement[]>([])
  const [earnedAchievements, setEarnedAchievements] = useState<UserAchievement[]>([])
  const [loading, setLoading] = useState(true)

  const loadAchievements = async () => {
    try {
      setLoading(true)
      const [all, earned] = await Promise.all([
        achievementsApi.getAllAchievements(),
        achievementsApi.getEarnedAchievements(),
      ])
      
      setAllAchievements(all || [])
      setEarnedAchievements(earned || [])
    } catch (error: any) {
      toast({
        title: tCommon('error'),
        description: error?.message || t('failed_to_load_achievements'),
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadAchievements()
  }, [])

  // Create a map of earned achievement IDs - Memoized
  // MUST be before conditional return to maintain hook order
  const earnedIds = useMemo(() => new Set(
    earnedAchievements.map(ea => {
      // Handle both nested and flat structures
      if (ea.achievement) {
        return ea.achievement.id
      }
      return ea.achievement_id
    })
  ), [earnedAchievements])

  // Separate achievements into earned and available - Memoized
  // MUST be before conditional return to maintain hook order
  const { earned, available } = useMemo(() => {
    const earnedList = allAchievements.filter(a => earnedIds.has(a.id))
    const availableList = allAchievements.filter(a => !earnedIds.has(a.id))
    return { earned: earnedList, available: availableList }
  }, [allAchievements, earnedIds])

  if (loading) {
    return <PageLoading translationKey="loading_achievements" />
  }

  return (
    <Tabs defaultValue="earned" className="space-y-6">
      <TabsList>
        <TabsTrigger value="earned">
          {t('earned_achievements')} ({earned.length})
        </TabsTrigger>
        <TabsTrigger value="available">
          {t('all_achievements')} ({allAchievements.length})
        </TabsTrigger>
      </TabsList>

      <TabsContent value="earned" className="space-y-6">
        {earned.length === 0 ? (
          <EmptyState
            icon={Trophy}
            title={t('no_earned')}
            description={t('no_earned_description')}
          />
        ) : (
          <Suspense fallback={
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {[1, 2, 3, 4, 5, 6].map(i => (
                <div key={i} className="h-[200px] bg-muted animate-pulse rounded-lg" />
              ))}
            </div>
          }>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {earned.map((achievement, index) => {
                const userAchievement = earnedAchievements.find(
                  ea => (ea.achievement?.id || ea.achievement_id) === achievement.id
                )
                return (
                  <AchievementCard
                    key={achievement.id || `earned-${index}`}
                    achievement={achievement}
                    earned={true}
                    earnedAt={userAchievement?.earned_at || userAchievement?.earned_at_flat}
                  />
                )
              })}
            </div>
          </Suspense>
        )}
      </TabsContent>

      <TabsContent value="available" className="space-y-6">
        {available.length === 0 ? (
          <EmptyState
            icon={Award}
            title={t('no_available') || t('no_achievements') || 'No achievements available'}
            description={t('all_achievements_earned')}
          />
        ) : (
          <Suspense fallback={
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {[1, 2, 3, 4, 5, 6].map(i => (
                <div key={i} className="h-[200px] bg-muted animate-pulse rounded-lg" />
              ))}
            </div>
          }>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {available.map((achievement, index) => (
                <AchievementCard
                  key={achievement.id || `available-${index}`}
                  achievement={achievement}
                  earned={false}
                />
              ))}
            </div>
          </Suspense>
        )}
      </TabsContent>
    </Tabs>
  )
}

