"use client"

import { AppLayout } from "@/components/layout/app-layout"
import { PageContainer } from "@/components/layout/page-container"
import { PageHeader } from "@/components/layout/page-header"
import { ProtectedRoute } from "@/components/auth/protected-route"
import { Button } from "@/components/ui/button"
import { CheckCheck } from "lucide-react"
import { useTranslations } from "@/lib/i18n"
import { PageLoading } from "@/components/ui/page-loading"
import { useState, lazy, Suspense } from "react"
import { notificationsApi } from "@/lib/api/notifications"
import { useToast } from "@/hooks/use-toast"

// Lazy load heavy components to improve initial load time
const NotificationsList = lazy(() => import("@/components/notifications/notifications-list").then(m => ({ default: m.NotificationsList })))

export default function NotificationsPage() {
  return (
    <ProtectedRoute>
      <NotificationsContent />
    </ProtectedRoute>
  )
}

function NotificationsContent() {
  const t = useTranslations('notifications')
  const tCommon = useTranslations('common')
  const [refreshKey, setRefreshKey] = useState(0)

  return (
    <AppLayout showSidebar={true} showFooter={false} hideNavbar={true} hideTopBar={true}>
      <PageHeader
        title={t('title') || tCommon('notifications')}
        subtitle={t('subtitle') || t('manage_your_notifications')}
        rightActions={
          <MarkAllReadButton onSuccess={() => setRefreshKey(prev => prev + 1)} />
        }
      />
      <PageContainer>
        {/* Notifications List */}
        <Suspense fallback={<PageLoading translationKey="loading" />}>
          <NotificationsList key={refreshKey} />
        </Suspense>
      </PageContainer>
    </AppLayout>
  )
}

function MarkAllReadButton({ onSuccess }: { onSuccess?: () => void }) {
  const t = useTranslations('notifications')
  const tCommon = useTranslations('common')
  const { toast } = useToast()
  const [loading, setLoading] = useState(false)

  const handleMarkAllRead = async () => {
    setLoading(true)
    try {
      await notificationsApi.markAllAsRead()
      toast({
        title: tCommon('success'),
        description: t('all_notifications_marked_read'),
      })
      onSuccess?.()
    } catch (error: any) {
      toast({
        title: tCommon('error'),
        description: error?.message || t('failed_to_mark_all_read'),
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <Button onClick={handleMarkAllRead} size="sm" disabled={loading}>
      <CheckCheck className="h-4 w-4 mr-2" />
      {loading ? tCommon('loading') : t('mark_all_read')}
    </Button>
  )
}

