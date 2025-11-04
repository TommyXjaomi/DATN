"use client"

import { useState, useEffect, useMemo, useCallback } from "react"
import { notificationsApi, type NotificationFilters } from "@/lib/api/notifications"
import { NotificationFiltersComponent } from "./notification-filters"
import { NotificationCard } from "./notification-card"
import { useToast } from "@/hooks/use-toast"
import { useTranslations } from "@/lib/i18n"
import { PageLoading } from "@/components/ui/page-loading"
import { EmptyState } from "@/components/ui/empty-state"
import { Bell } from "lucide-react"
import { Button } from "@/components/ui/button"
import type { Notification } from "@/types"

export function NotificationsList() {
  const t = useTranslations('notifications')
  const tCommon = useTranslations('common')
  const { toast } = useToast()
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [loading, setLoading] = useState(true)
  const [filters, setFilters] = useState<NotificationFilters>({})
  const [page, setPage] = useState(1)
  const [hasMore, setHasMore] = useState(true)

  // Memoize filter key to trigger refetch only when filters actually change
  const filterKey = useMemo(() => {
    return JSON.stringify({
      is_read: filters.is_read !== undefined ? filters.is_read : '',
      type: filters.type?.sort().join(',') || '',
      category: filters.category?.sort().join(',') || '',
      sort_by: filters.sort_by || '',
      sort_order: filters.sort_order || '',
      date_from: filters.date_from || '',
      date_to: filters.date_to || '',
    })
  }, [filters.is_read, filters.type, filters.category, filters.sort_by, filters.sort_order, filters.date_from, filters.date_to])

  const loadNotifications = useCallback(async () => {
    try {
      setLoading(true)
      const response = await notificationsApi.getNotifications(filters, page, 20)
      const newNotifications = response.notifications || []
      
      setNotifications(prev => 
        page === 1 ? newNotifications : [...prev, ...newNotifications]
      )
      
      // Use total_pages from backend response
      const totalPages = response.pagination?.total_pages || 0
      setHasMore(page < totalPages)
    } catch (error: any) {
      console.error('[Notifications] Error loading notifications:', error)
      toast({
        title: tCommon('error'),
        description: error?.message || t('failed_to_load_notifications'),
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }, [filters, page, toast, tCommon, t])

  useEffect(() => {
    loadNotifications()
  }, [loadNotifications, filterKey])

  const handleMarkAsRead = async (notificationId: string) => {
    try {
      await notificationsApi.markAsRead(notificationId)
      setNotifications(notifications.map(n => 
        n.id === notificationId 
          ? { ...n, isRead: true, is_read: true, read: true }
          : n
      ))
    } catch (error: any) {
      console.error('[Notifications] Error marking as read:', error)
    }
  }

  const handleDelete = async (notificationId: string) => {
    try {
      await notificationsApi.deleteNotification(notificationId)
      setNotifications(notifications.filter(n => n.id !== notificationId))
      toast({
        title: tCommon('success'),
        description: t('notification_deleted'),
      })
    } catch (error: any) {
      toast({
        title: tCommon('error'),
        description: error?.message || t('failed_to_delete_notification'),
        variant: "destructive",
      })
    }
  }

  const refreshList = () => {
    setPage(1)
    loadNotifications()
  }

  const handleFiltersChange = (newFilters: NotificationFilters) => {
    setFilters(newFilters)
    setPage(1)
  }

  if (loading && page === 1) {
    return <PageLoading translationKey="loading" />
  }

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div>
        <NotificationFiltersComponent filters={filters} onFiltersChange={handleFiltersChange} />
      </div>

      {/* Notifications List */}
      {notifications.length === 0 && !loading ? (
        <EmptyState
          icon={Bell}
          title={t('no_notifications')}
          description={t('no_notifications_description')}
        />
      ) : (
        <div className="space-y-4">
          {notifications.map((notification) => (
            <NotificationCard
              key={notification.id}
              notification={notification}
              onMarkAsRead={handleMarkAsRead}
              onDelete={handleDelete}
            />
          ))}
        </div>
      )}

      {/* Load More Button */}
      {hasMore && !loading && (
        <div className="flex justify-center pt-4">
          <Button
            variant="outline"
            onClick={() => setPage(prev => prev + 1)}
            disabled={loading}
          >
            {loading ? tCommon('loading') : tCommon('load_more')}
          </Button>
        </div>
      )}
    </div>
  )
}

