"use client"

import { useState } from "react"
import { X, Filter, Check, ArrowUpDown, Calendar } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet"
import { Label } from "@/components/ui/label"
import { Checkbox } from "@/components/ui/checkbox"
import { Separator } from "@/components/ui/separator"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Input } from "@/components/ui/input"
import { cn } from "@/lib/utils"
import type { NotificationFilters } from "@/lib/api/notifications"
import { useTranslations } from '@/lib/i18n'

interface NotificationFiltersProps {
  filters: NotificationFilters
  onFiltersChange: (filters: NotificationFilters) => void
}

const TYPE_OPTIONS = [
  { value: "achievement", color: "bg-green-500" },
  { value: "reminder", color: "bg-blue-500" },
  { value: "course_update", color: "bg-purple-500" },
  { value: "exercise_graded", color: "bg-orange-500" },
  { value: "system", color: "bg-gray-500" },
  { value: "social", color: "bg-pink-500" },
]

const CATEGORY_OPTIONS = [
  { value: "info", color: "bg-blue-500" },
  { value: "success", color: "bg-green-500" },
  { value: "warning", color: "bg-yellow-500" },
  { value: "alert", color: "bg-red-500" },
]

export function NotificationFiltersComponent({ filters, onFiltersChange }: NotificationFiltersProps) {
  const t = useTranslations('common')
  const tNotifications = useTranslations('notifications')
  
  const [isOpen, setIsOpen] = useState(false)

  const handleTypeChange = (type: string) => {
    const currentTypes = filters.type || []
    const newTypes = currentTypes.includes(type)
      ? currentTypes.filter((t) => t !== type)
      : [...currentTypes, type]
    onFiltersChange({ ...filters, type: newTypes.length > 0 ? newTypes : undefined })
  }

  const handleCategoryChange = (category: string) => {
    const currentCategories = filters.category || []
    const newCategories = currentCategories.includes(category)
      ? currentCategories.filter((c) => c !== category)
      : [...currentCategories, category]
    onFiltersChange({ ...filters, category: newCategories.length > 0 ? newCategories : undefined })
  }

  const handleClearFilters = () => {
    onFiltersChange({
      is_read: undefined,
      type: undefined,
      category: undefined,
      sort_by: undefined,
      sort_order: undefined,
      date_from: undefined,
      date_to: undefined,
    })
    if (isOpen) {
      setIsOpen(false)
    }
  }

  const activeFilterCount =
    (filters.is_read !== undefined ? 1 : 0) +
    (filters.type?.length || 0) +
    (filters.category?.length || 0) +
    (filters.sort_by ? 1 : 0) +
    (filters.date_from ? 1 : 0) +
    (filters.date_to ? 1 : 0)

  return (
    <div className="space-y-5">
      {/* Quick Sort Bar */}
      <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center">
        <div className="flex items-center gap-2 text-sm font-medium text-muted-foreground">
          <ArrowUpDown className="w-4 h-4" />
          <span>{t('sort_by')}:</span>
        </div>
        <div className="flex gap-3 flex-1 w-full sm:w-auto">
          <Select
            value={filters.sort_by || "date"}
            onValueChange={(value) => {
              const newFilters = { ...filters, sort_by: value as 'date' }
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

      {/* Filter Button */}
      <div className="flex items-center gap-3">
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
                <SheetTitle className="text-2xl font-bold tracking-tight">{t('filter_notifications')}</SheetTitle>
                <p className="text-sm text-muted-foreground mt-1.5">
                  {t('filter_notifications_description')}
                </p>
              </SheetHeader>
            </div>

            <div className="px-6 py-6 space-y-8">
              {/* Read Status */}
              <div className="space-y-4">
                <div>
                  <Label className="text-base font-semibold text-foreground">{t('read_status')}</Label>
                  <p className="text-xs text-muted-foreground mt-1">{t('filter_by_read_status')}</p>
                </div>
                <div className="space-y-2.5">
                  {[
                    { value: true, label: t('read') },
                    { value: false, label: t('unread') },
                  ].map((option) => {
                    const isSelected = filters.is_read === option.value
                    return (
                      <label
                        key={String(option.value)}
                        htmlFor={`read-${option.value}`}
                        className={cn(
                          "flex items-center gap-3 p-3 rounded-lg border-2 cursor-pointer transition-all",
                          "hover:bg-muted/50 hover:border-primary/30",
                          isSelected && "bg-primary/5 border-primary shadow-sm"
                        )}
                      >
                        <Checkbox
                          id={`read-${option.value}`}
                          checked={isSelected}
                          onCheckedChange={() => {
                            onFiltersChange({ ...filters, is_read: isSelected ? undefined : option.value })
                          }}
                          className="w-5 h-5"
                        />
                        <span className={cn(
                          "flex-1 text-sm font-medium transition-colors",
                          isSelected && "text-primary"
                        )}>
                          {option.label}
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

              {/* Type */}
              <div className="space-y-4">
                <div>
                  <Label className="text-base font-semibold text-foreground">{t('type')}</Label>
                  <p className="text-xs text-muted-foreground mt-1">{t('select_one_or_more')}</p>
                </div>
                <div className="space-y-2.5">
                  {TYPE_OPTIONS.map((option) => {
                    const isSelected = filters.type?.includes(option.value) || false
                    return (
                      <label
                        key={option.value}
                        htmlFor={`type-${option.value}`}
                        className={cn(
                          "flex items-center gap-3 p-3 rounded-lg border-2 cursor-pointer transition-all",
                          "hover:bg-muted/50 hover:border-primary/30",
                          isSelected && "bg-primary/5 border-primary shadow-sm"
                        )}
                      >
                        <Checkbox
                          id={`type-${option.value}`}
                          checked={isSelected}
                          onCheckedChange={() => handleTypeChange(option.value)}
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

              {/* Category */}
              <div className="space-y-4">
                <div>
                  <Label className="text-base font-semibold text-foreground">{t('category')}</Label>
                  <p className="text-xs text-muted-foreground mt-1">{t('select_one_or_more')}</p>
                </div>
                <div className="space-y-2.5">
                  {CATEGORY_OPTIONS.map((option) => {
                    const isSelected = filters.category?.includes(option.value) || false
                    return (
                      <label
                        key={option.value}
                        htmlFor={`category-${option.value}`}
                        className={cn(
                          "flex items-center gap-3 p-3 rounded-lg border-2 cursor-pointer transition-all",
                          "hover:bg-muted/50 hover:border-primary/30",
                          isSelected && "bg-primary/5 border-primary shadow-sm"
                        )}
                      >
                        <Checkbox
                          id={`category-${option.value}`}
                          checked={isSelected}
                          onCheckedChange={() => handleCategoryChange(option.value)}
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

      {/* Active Filters */}
      {activeFilterCount > 0 && (
        <div className="flex items-center gap-2 flex-wrap py-2">
          <span className="text-sm font-medium text-muted-foreground mr-1">{t('active_filters')}:</span>
          {filters.is_read !== undefined && (
            <Badge 
              variant="secondary" 
              className="gap-1.5 px-3 py-1.5 text-sm font-medium border shadow-sm hover:shadow-md transition-shadow"
            >
              {filters.is_read ? t('read') : t('unread')}
              <button
                onClick={() => onFiltersChange({ ...filters, is_read: undefined })}
                className="ml-1 hover:bg-muted-foreground/20 rounded-full p-0.5 transition-colors"
                aria-label={t('remove_read_filter')}
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </Badge>
          )}
          {filters.type?.map((type) => {
            const option = TYPE_OPTIONS.find((t) => t.value === type)
            return option ? (
              <Badge 
                key={type}
                variant="secondary" 
                className="gap-1.5 px-3 py-1.5 text-sm font-medium border shadow-sm hover:shadow-md transition-shadow"
              >
                <span className={`w-2.5 h-2.5 rounded-full ${option.color} shadow-sm`}></span>
                {t(type)}
                <button
                  onClick={() => handleTypeChange(type)}
                  className="ml-1 hover:bg-muted-foreground/20 rounded-full p-0.5 transition-colors"
                  aria-label={t('remove_type_filter')}
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </Badge>
            ) : null
          })}
          {filters.category?.map((category) => {
            const option = CATEGORY_OPTIONS.find((c) => c.value === category)
            return option ? (
              <Badge 
                key={category}
                variant="secondary" 
                className="gap-1.5 px-3 py-1.5 text-sm font-medium border shadow-sm hover:shadow-md transition-shadow"
              >
                <span className={`w-2.5 h-2.5 rounded-full ${option.color} shadow-sm`}></span>
                {t(category)}
                <button
                  onClick={() => handleCategoryChange(category)}
                  className="ml-1 hover:bg-muted-foreground/20 rounded-full p-0.5 transition-colors"
                  aria-label={t('remove_category_filter')}
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </Badge>
            ) : null
          })}
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

