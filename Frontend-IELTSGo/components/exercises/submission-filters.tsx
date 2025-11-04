"use client"

import { useState, useEffect } from "react"
import { Search, X, Filter, Check, ArrowUpDown, Calendar } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { Label } from "@/components/ui/label"
import { Checkbox } from "@/components/ui/checkbox"
import { Separator } from "@/components/ui/separator"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Input } from "@/components/ui/input"
import { cn } from "@/lib/utils"
import type { SubmissionFilters } from "@/lib/api/exercises"
import { useTranslations } from '@/lib/i18n'
import { useDebounce } from "@/lib/hooks/use-debounce"

interface SubmissionFiltersProps {
  filters: SubmissionFilters
  onFiltersChange: (filters: SubmissionFilters) => void
  onSearch?: (search: string) => void
  hideStatusFilter?: boolean // Hide status filter (for My Exercises page)
}

const SKILL_OPTIONS = [
  { value: "listening", color: "bg-blue-500" },
  { value: "reading", color: "bg-green-500" },
  { value: "writing", color: "bg-orange-500" },
  { value: "speaking", color: "bg-purple-500" },
]

const STATUS_OPTIONS = [
  { value: "completed", color: "bg-green-500" },
  { value: "in_progress", color: "bg-yellow-500" },
  { value: "abandoned", color: "bg-gray-500" },
]

export function SubmissionFiltersComponent({ filters, onFiltersChange, onSearch, hideStatusFilter = false }: SubmissionFiltersProps) {
  const t = useTranslations('common')
  const tExercises = useTranslations('exercises')
  
  const [isOpen, setIsOpen] = useState(false)
  const [searchValue, setSearchValue] = useState(filters.search || "")
  
  // Debounce search input to reduce API calls
  const debouncedSearch = useDebounce(searchValue, 500)
  
  // Sync searchValue when filters.search changes externally
  useEffect(() => {
    setSearchValue(filters.search || "")
  }, [filters.search])
  
  // Auto-search when debounced value changes (after 500ms of no typing)
  useEffect(() => {
    if (onSearch && debouncedSearch !== (filters.search || "")) {
      onSearch(debouncedSearch)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedSearch]) // Only depend on debouncedSearch to avoid infinite loop

  const handleSkillChange = (skill: string) => {
    const currentSkills = filters.skill || []
    const newSkills = currentSkills.includes(skill)
      ? currentSkills.filter((s) => s !== skill)
      : [...currentSkills, skill]
    onFiltersChange({ ...filters, skill: newSkills.length > 0 ? newSkills : undefined })
  }

  const handleStatusChange = (status: string) => {
    const currentStatuses = filters.status || []
    const newStatuses = currentStatuses.includes(status)
      ? currentStatuses.filter((s) => s !== status)
      : [...currentStatuses, status]
    onFiltersChange({ ...filters, status: newStatuses.length > 0 ? newStatuses : undefined })
  }

  const handleClearFilters = () => {
    const clearedFilters: SubmissionFilters = {
      skill: undefined,
      status: hideStatusFilter ? filters.status : undefined, // Keep status if hidden
      sort_by: undefined,
      sort_order: undefined,
      date_from: undefined,
      date_to: undefined,
      search: undefined,
    }
    onFiltersChange(clearedFilters)
    if (onSearch) {
      onSearch("")
    }
    setSearchValue("")
    if (isOpen) {
      setIsOpen(false)
    }
  }

  const activeFilterCount =
    (filters.skill?.length || 0) +
    (!hideStatusFilter ? (filters.status?.length || 0) : 0) +
    (filters.sort_by ? 1 : 0) +
    (filters.date_from ? 1 : 0) +
    (filters.date_to ? 1 : 0) +
    (filters.search ? 1 : 0)

  return (
    <div className="space-y-5">
      {/* Quick Sort Bar - Always visible at top */}
      <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center">
        <div className="flex items-center gap-2 text-sm font-medium text-muted-foreground">
          <ArrowUpDown className="w-4 h-4" />
          <span>{t('sort_by')}:</span>
        </div>
        <div className="flex gap-3 flex-1 w-full sm:w-auto">
          <Select
            value={filters.sort_by || "date"}
            onValueChange={(value) => {
              const newFilters = { ...filters, sort_by: value as 'date' | 'score' | 'band_score' }
              if (!newFilters.sort_order) {
                newFilters.sort_order = "desc"
              }
              onFiltersChange(newFilters)
            }}
          >
            <SelectTrigger className="w-full sm:w-[180px] h-11 border-2">
              <SelectValue placeholder={t('select_sort_option')} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="date">{t('date')}</SelectItem>
              <SelectItem value="score">{t('score')}</SelectItem>
              <SelectItem value="band_score">{tExercises('ielts_band_score')}</SelectItem>
            </SelectContent>
          </Select>
          <Select
            value={filters.sort_order || "desc"}
            onValueChange={(value) => onFiltersChange({ ...filters, sort_order: value as "asc" | "desc" })}
            disabled={!filters.sort_by}
          >
            <SelectTrigger className="w-full sm:w-[150px] h-11 border-2" disabled={!filters.sort_by}>
              <SelectValue placeholder={t('sort_order')} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="desc">{t('descending')}</SelectItem>
              <SelectItem value="asc">{t('ascending')}</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* Search Bar with Filter button */}
      {onSearch && (
        <div className="flex gap-3">
          <div className="relative flex-1 group">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground transition-colors group-focus-within:text-primary" />
            <Input
              placeholder={tExercises('search_submissions_by_exercise_title') || t('search') || "Search by exercise title..."}
              value={searchValue}
              onChange={(e) => setSearchValue(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Enter") {
                  onSearch(searchValue)
                }
              }}
              className="pl-12 h-12 text-base border-2 focus:border-primary transition-all shadow-sm"
            />
          </div>
          <Button 
            onClick={() => onSearch(searchValue)} 
            className="h-12 px-8 text-base font-medium shadow-md hover:shadow-lg transition-shadow"
          >
            {t('search')}
          </Button>
          <Sheet open={isOpen} onOpenChange={setIsOpen}>
            <SheetTrigger asChild>
              <Button 
                variant="outline" 
                className="relative h-12 px-5 border-2 hover:border-primary transition-all shadow-sm"
              >
                <Filter className="w-4 h-4 mr-2" />
                <span className="font-medium">{t('filters')}</span>
                {activeFilterCount > 0 && (
                  <Badge
                    className="absolute -top-2 -right-2 w-6 h-6 p-0 flex items-center justify-center text-xs font-bold bg-primary text-primary-foreground shadow-md"
                  >
                    {activeFilterCount}
                  </Badge>
                )}
              </Button>
            </SheetTrigger>
          <SheetContent className="w-full sm:max-w-lg overflow-y-auto p-0">
            <div className="sticky top-0 bg-background z-10 border-b px-6 py-5 shadow-sm">
              <SheetHeader>
                <SheetTitle className="text-2xl font-bold tracking-tight">{t('filter_submissions')}</SheetTitle>
                <p className="text-sm text-muted-foreground mt-1.5">
                  {t('filter_submissions_description')}
                </p>
              </SheetHeader>
            </div>

            <div className="px-6 py-6 space-y-8">
              {/* Sort */}
              <div className="space-y-4 bg-muted/30 p-4 rounded-lg border-2 border-dashed">
                <div>
                  <Label className="text-base font-semibold text-foreground">{t('sort_by')}</Label>
                  <p className="text-xs text-muted-foreground mt-1">{t('choose_sort_option')}</p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <Select
                    value={filters.sort_by || "date"}
                    onValueChange={(value) => {
                      const newFilters = { ...filters, sort_by: value as 'date' | 'score' | 'band_score' }
                      if (!newFilters.sort_order) {
                        newFilters.sort_order = "desc"
                      }
                      onFiltersChange(newFilters)
                    }}
                  >
                    <SelectTrigger className="w-full h-11">
                      <SelectValue placeholder={t('select_sort_option')} />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="date">{t('date')}</SelectItem>
                      <SelectItem value="score">{t('score')}</SelectItem>
                      <SelectItem value="band_score">{tExercises('ielts_band_score')}</SelectItem>
                    </SelectContent>
                  </Select>
                  <Select
                    value={filters.sort_order || "desc"}
                    onValueChange={(value) => onFiltersChange({ ...filters, sort_order: value as "asc" | "desc" })}
                    disabled={!filters.sort_by}
                  >
                    <SelectTrigger className="w-full h-11" disabled={!filters.sort_by}>
                      <SelectValue placeholder={t('sort_order')} />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="desc">{t('descending')}</SelectItem>
                      <SelectItem value="asc">{t('ascending')}</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <Separator className="my-6" />

              {/* Skill Type */}
              <div className="space-y-4">
                <div>
                  <Label className="text-base font-semibold text-foreground">{t('skill_type')}</Label>
                  <p className="text-xs text-muted-foreground mt-1">{t('select_one_or_more')}</p>
                </div>
                <div className="space-y-2.5">
                  {SKILL_OPTIONS.map((option) => {
                    const isSelected = filters.skill?.includes(option.value) || false
                    return (
                      <label
                        key={option.value}
                        htmlFor={`skill-${option.value}`}
                        className={cn(
                          "flex items-center gap-3 p-3 rounded-lg border-2 cursor-pointer transition-all",
                          "hover:bg-muted/50 hover:border-primary/30",
                          isSelected && "bg-primary/5 border-primary shadow-sm"
                        )}
                      >
                        <Checkbox
                          id={`skill-${option.value}`}
                          checked={isSelected}
                          onCheckedChange={() => handleSkillChange(option.value)}
                          className="w-5 h-5"
                        />
                        <span className={`w-3 h-3 rounded-full ${option.color} shadow-sm`}></span>
                        <span className={cn(
                          "flex-1 text-sm font-medium transition-colors",
                          isSelected && "text-primary"
                        )}>
                          {t(option.value)}
                        </span>
                        {isSelected && (
                          <Check className="w-4 h-4 text-primary" />
                        )}
                      </label>
                    )
                  })}
                </div>
              </div>

              <Separator className="my-6" />

              {/* Status */}
              {!hideStatusFilter && (
                <>
                  <div className="space-y-4">
                    <div>
                      <Label className="text-base font-semibold text-foreground">{t('status')}</Label>
                      <p className="text-xs text-muted-foreground mt-1">{t('select_one_or_more')}</p>
                    </div>
                    <div className="space-y-2.5">
                      {STATUS_OPTIONS.map((option) => {
                        const isSelected = filters.status?.includes(option.value) || false
                        return (
                          <label
                            key={option.value}
                            htmlFor={`status-${option.value}`}
                            className={cn(
                              "flex items-center gap-3 p-3 rounded-lg border-2 cursor-pointer transition-all",
                              "hover:bg-muted/50 hover:border-primary/30",
                              isSelected && "bg-primary/5 border-primary shadow-sm"
                            )}
                          >
                            <Checkbox
                              id={`status-${option.value}`}
                              checked={isSelected}
                              onCheckedChange={() => handleStatusChange(option.value)}
                              className="w-5 h-5"
                            />
                            <span className={`w-3 h-3 rounded-full ${option.color} shadow-sm`}></span>
                            <span className={cn(
                              "flex-1 text-sm font-medium transition-colors",
                              isSelected && "text-primary"
                            )}>
                              {t(option.value === 'in_progress' ? 'in_progress' : option.value)}
                            </span>
                            {isSelected && (
                              <Check className="w-4 h-4 text-primary" />
                            )}
                          </label>
                        )
                      })}
                    </div>
                  </div>

                  <Separator className="my-6" />
                </>
              )}

              {/* Date Range */}
              <div className="space-y-4">
                <div>
                  <Label className="text-base font-semibold text-foreground">{t('date_range')}</Label>
                  <p className="text-xs text-muted-foreground mt-1">{t('select_date_range')}</p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  <div className="space-y-2">
                    <Label className="text-sm">{t('from_date')}</Label>
                    <Input
                      type="date"
                      value={filters.date_from || ""}
                      onChange={(e) => onFiltersChange({ ...filters, date_from: e.target.value || undefined })}
                      className="h-11"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-sm">{t('to_date')}</Label>
                    <Input
                      type="date"
                      value={filters.date_to || ""}
                      onChange={(e) => onFiltersChange({ ...filters, date_to: e.target.value || undefined })}
                      className="h-11"
                    />
                  </div>
                </div>
              </div>
            </div>

            {/* Footer Actions */}
            <div className="sticky bottom-0 bg-background border-t px-6 py-4 shadow-lg">
              <div className="flex gap-3">
                <Button 
                  variant="outline" 
                  className="flex-1 h-11 font-medium" 
                  onClick={handleClearFilters}
                  disabled={activeFilterCount === 0}
                >
                  <X className="w-4 h-4 mr-2" />
                  {t('clear_all')}
                </Button>
                <Button 
                  className="flex-1 h-11 font-medium shadow-md hover:shadow-lg transition-shadow" 
                  onClick={() => setIsOpen(false)}
                >
                  {t('apply_filters')}
                  {activeFilterCount > 0 && (
                    <Badge className="ml-2 bg-primary-foreground text-primary">
                      {activeFilterCount}
                    </Badge>
                  )}
                </Button>
              </div>
            </div>
          </SheetContent>
        </Sheet>
        </div>
      )}

      {/* Active Filters */}
      {activeFilterCount > 0 && (
        <div className="flex items-center gap-2 flex-wrap py-2">
          <span className="text-sm font-medium text-muted-foreground mr-1">{t('active_filters')}:</span>
          {filters.skill?.map((skill) => {
            const option = SKILL_OPTIONS.find((s) => s.value === skill)
            return option ? (
              <Badge 
                key={skill}
                variant="secondary" 
                className="gap-1.5 px-3 py-1.5 text-sm font-medium border shadow-sm hover:shadow-md transition-shadow"
              >
                <span className={`w-2.5 h-2.5 rounded-full ${option.color} shadow-sm`}></span>
                {t(skill)}
                <button
                  onClick={() => handleSkillChange(skill)}
                  className="ml-1 hover:bg-muted-foreground/20 rounded-full p-0.5 transition-colors"
                  aria-label={t('remove_skill_filter')}
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </Badge>
            ) : null
          })}
          {filters.status?.map((status) => {
            const option = STATUS_OPTIONS.find((s) => s.value === status)
            return option ? (
              <Badge 
                key={status}
                variant="secondary" 
                className="gap-1.5 px-3 py-1.5 text-sm font-medium border shadow-sm hover:shadow-md transition-shadow"
              >
                <span className={`w-2.5 h-2.5 rounded-full ${option.color} shadow-sm`}></span>
                {t(status === 'in_progress' ? 'in_progress' : status)}
                <button
                  onClick={() => handleStatusChange(status)}
                  className="ml-1 hover:bg-muted-foreground/20 rounded-full p-0.5 transition-colors"
                  aria-label={t('remove_status_filter')}
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </Badge>
            ) : null
          })}
          {filters.sort_by && (
            <Badge 
              variant="secondary" 
              className="gap-1.5 px-3 py-1.5 text-sm font-medium border shadow-sm hover:shadow-md transition-shadow"
            >
              <ArrowUpDown className="w-3.5 h-3.5" />
              <span>{filters.sort_by === 'band_score' ? tExercises('ielts_band_score') : t(filters.sort_by)}</span>
              {filters.sort_order && (
                <span className="text-muted-foreground">
                  ({filters.sort_order === "asc" ? t('ascending') : t('descending')})
                </span>
              )}
              <button
                onClick={() => onFiltersChange({ ...filters, sort_by: undefined, sort_order: undefined })}
                className="ml-1 hover:bg-muted-foreground/20 rounded-full p-0.5 transition-colors"
                aria-label={t('remove_sort_filter')}
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </Badge>
          )}
          {(filters.date_from || filters.date_to) && (
            <Badge 
              variant="secondary" 
              className="gap-1.5 px-3 py-1.5 text-sm font-medium border shadow-sm hover:shadow-md transition-shadow"
            >
              <Calendar className="w-3.5 h-3.5" />
              <span>
                {filters.date_from && filters.date_to
                  ? `${filters.date_from} - ${filters.date_to}`
                  : filters.date_from
                  ? `${t('from')} ${filters.date_from}`
                  : `${t('to')} ${filters.date_to}`}
              </span>
              <button
                onClick={() => onFiltersChange({ ...filters, date_from: undefined, date_to: undefined })}
                className="ml-1 hover:bg-muted-foreground/20 rounded-full p-0.5 transition-colors"
                aria-label={t('remove_date_filter')}
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </Badge>
          )}
          <Button 
            variant="ghost" 
            size="sm" 
            onClick={handleClearFilters} 
            className="h-8 px-3 text-sm font-medium text-muted-foreground hover:text-destructive hover:bg-destructive/10 transition-all"
          >
            <X className="w-3.5 h-3.5 mr-1.5" />
            {t('clear_all')}
          </Button>
        </div>
      )}
    </div>
  )
}

