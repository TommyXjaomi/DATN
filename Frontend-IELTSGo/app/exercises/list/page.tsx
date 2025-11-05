"use client"

import { useState, useEffect, useCallback, useMemo } from "react"
import { AppLayout } from "@/components/layout/app-layout"
import { PageContainer } from "@/components/layout/page-container"
import { ExerciseCard } from "@/components/exercises/exercise-card"
import { ExerciseFiltersComponent } from "@/components/exercises/exercise-filters"
import { Button } from "@/components/ui/button"
import { PageLoading } from "@/components/ui/page-loading"
import { SkeletonCard } from "@/components/ui/skeleton-card"
import { EmptyState } from "@/components/ui/empty-state"
import { Target } from "lucide-react"
import { exercisesApi, type ExerciseFilters } from "@/lib/api/exercises"
import type { Exercise } from "@/types"
import { useTranslations } from '@/lib/i18n'
import { usePullToRefresh } from "@/lib/hooks/use-swipe-gestures"

export default function ExercisesListPage() {

  const t = useTranslations('exercises')
  const tCommon = useTranslations('common')

  const [exercises, setExercises] = useState<Exercise[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [filters, setFilters] = useState<ExerciseFilters>({
    skill: [],
    type: [],
    difficulty: [],
    search: "",
  })
  const [showOnlyStandalone, setShowOnlyStandalone] = useState(false)
  const [page, setPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)

  // Use stable filter key to trigger refetch only when filters actually change
  const filterKey = useMemo(() => {
    return JSON.stringify({
      skill: filters.skill?.sort().join(',') || '',
      type: filters.type?.sort().join(',') || '',
      difficulty: filters.difficulty?.sort().join(',') || '',
      search: filters.search || '',
      sort: filters.sort || '',
      sort_order: filters.sort_order || '',
    })
  }, [filters.skill, filters.type, filters.difficulty, filters.search, filters.sort, filters.sort_order])

  // Fetch exercises when filters, page, or sourceFilter changes
  useEffect(() => {
    let isMounted = true
    
    const fetchExercises = async () => {
      try {
        setLoading(true)
        setError(null)
        const response = await exercisesApi.getExercises(filters, page, 12)

        if (!isMounted) return

        // Show all exercises, but filter standalone if toggle is ON
        let filteredExercises = response.data
        if (showOnlyStandalone) {
          filteredExercises = response.data.filter(ex => ex.course_id === null || ex.course_id === undefined)
        }

        setExercises(filteredExercises)
        // Use totalPages from API response, not from filtered results
        // Note: If sourceFilter is applied, we need to recalculate based on filtered count
        // But for now, use API totalPages for better UX (shows total available)
        setTotalPages(response.totalPages)
      } catch (error) {
        if (!isMounted) return
        console.error('[Exercises List] Failed to fetch:', error)
        setError(t('failed_to_load_exercises_please_try_agai'))
        setExercises([])
      } finally {
        if (isMounted) {
          setLoading(false)
        }
      }
    }

    fetchExercises()

    return () => {
      isMounted = false
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filterKey, page, showOnlyStandalone]) // filterKey is stable string, page and showOnlyStandalone are primitives

  // Refetch function for pull to refresh
  const refetchExercises = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      const response = await exercisesApi.getExercises(filters, page, 12)

      // Show all exercises, but filter standalone if toggle is ON
      let filteredExercises = response.data
      if (showOnlyStandalone) {
        filteredExercises = response.data.filter(ex => ex.course_id === null || ex.course_id === undefined)
      }

      setExercises(filteredExercises)
      setTotalPages(response.totalPages)
    } catch (error) {
      console.error('[Exercises List] Failed to fetch:', error)
      setError(t('failed_to_load_exercises_please_try_agai'))
      setExercises([])
    } finally {
      setLoading(false)
    }
  }, [filters, page, showOnlyStandalone, t])

  // Pull to refresh
  const { ref: pullToRefreshRef } = usePullToRefresh(() => {
    refetchExercises()
  }, true)

  const handleFiltersChange = (newFilters: ExerciseFilters) => {
    // Remove undefined and empty values to ensure clean filter state
    const cleanFilters: ExerciseFilters = {}
    if (newFilters.search && newFilters.search.trim()) {
      cleanFilters.search = newFilters.search.trim()
    }
    if (newFilters.skill && newFilters.skill.length > 0) {
      cleanFilters.skill = newFilters.skill
    }
    if (newFilters.type && newFilters.type.length > 0) {
      cleanFilters.type = newFilters.type
    }
    if (newFilters.difficulty && newFilters.difficulty.length > 0) {
      cleanFilters.difficulty = newFilters.difficulty
    }
    if (newFilters.sort) {
      cleanFilters.sort = newFilters.sort
      // Always include sort_order when sort is set
      cleanFilters.sort_order = newFilters.sort_order || "desc"
    }
    // Always set to clean object (even if empty) to clear all filters
    setFilters(cleanFilters)
    setPage(1)
  }

  const handleSearch = (search: string) => {
    setFilters((prev) => ({ ...prev, search: search || undefined }))
    setPage(1)
  }

  return (
    <AppLayout showFooter={true}>
      <div ref={pullToRefreshRef as React.RefObject<HTMLDivElement>}>
      <PageContainer>
        <div className="mb-8">
          <h1 className="text-3xl font-bold tracking-tight mb-2">{t('ielts_exercises')}</h1>
          <p className="text-base text-muted-foreground">
            {t('exercises_description')}
          </p>
          <div className="flex items-center gap-4 mt-4">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={showOnlyStandalone}
                onChange={(e) => setShowOnlyStandalone(e.target.checked)}
                className="w-4 h-4"
              />
              <span className="text-sm text-muted-foreground">
                {t('show_only_standalone') || 'Chỉ hiển thị bài tập độc lập'}
              </span>
            </label>
            <span className="text-xs text-muted-foreground">
              💡 {t('exercises_from_courses_info') || 'Bài tập thuộc khóa học được hiển thị ở đây và trong trang khóa học tương ứng'}
            </span>
          </div>
        </div>

        <ExerciseFiltersComponent filters={filters} onFiltersChange={handleFiltersChange} onSearch={handleSearch} />

        {loading ? (
          <>
            <SkeletonCard gridCols={3} count={6} className="mt-8" />
          </>
        ) : error ? (
          <EmptyState
            icon={Target}
            title={error}
            description={tCommon('please_try_again_later') || "Please try again later"}
            actionLabel={tCommon('try_again') || "Try Again"}
            actionOnClick={refetchExercises}
            className="mt-8"
          />
        ) : exercises.length === 0 ? (
          <EmptyState
            icon={Target}
            title={t('no_exercises_found_matching_your_criteri')}
            description={tCommon('try_adjusting_your_filters') || "Try adjusting your filters or search terms"}
            actionLabel={tCommon('clear_filters') || "Clear Filters"}
            actionOnClick={() => handleFiltersChange({})}
            className="mt-8"
          />
        ) : (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-8">
              {exercises.map((exercise) => (
                <ExerciseCard key={exercise.id} exercise={exercise} />
              ))}
            </div>

            {totalPages > 1 && (
              <div className="flex items-center justify-center gap-2 mt-8">
                <Button
                  variant="outline"
                  disabled={page === 1}
                  onClick={() => setPage(page - 1)}
                  className="bg-transparent"
                >
                  {tCommon('previous')}
                </Button>
                <span className="text-sm text-muted-foreground">
                  {tCommon('page_of', { page: page.toString(), totalPages: totalPages.toString() })}
                </span>
                <Button
                  variant="outline"
                  disabled={page === totalPages}
                  onClick={() => setPage(page + 1)}
                  className="bg-transparent"
                >
                  {tCommon('next')}
                </Button>
              </div>
            )}
          </>
        )}
      </PageContainer>
      </div>
    </AppLayout>
  )
}
