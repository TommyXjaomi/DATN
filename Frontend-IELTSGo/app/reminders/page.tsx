"use client"

import { AppLayout } from "@/components/layout/app-layout"
import { PageContainer } from "@/components/layout/page-container"
import { PageHeader } from "@/components/layout/page-header"
import { ProtectedRoute } from "@/components/auth/protected-route"
import { Button } from "@/components/ui/button"
import { Plus } from "lucide-react"
import { useTranslations } from "@/lib/i18n"
import { PageLoading } from "@/components/ui/page-loading"
import { useState, lazy, Suspense } from "react"

// Lazy load heavy components to improve initial load time
const RemindersList = lazy(() => import("@/components/reminders/reminders-list").then(m => ({ default: m.RemindersList })))
const CreateReminderDialog = lazy(() => import("@/components/reminders/create-reminder-dialog").then(m => ({ default: m.CreateReminderDialog })))

export default function RemindersPage() {
  return (
    <ProtectedRoute>
      <RemindersContent />
    </ProtectedRoute>
  )
}

function RemindersContent() {
  const t = useTranslations('reminders')
  const tCommon = useTranslations('common')
  const [createDialogOpen, setCreateDialogOpen] = useState(false)
  const [refreshTrigger, setRefreshTrigger] = useState(0)

  const handleReminderCreated = () => {
    setRefreshTrigger(prev => prev + 1)
  }

  return (
    <AppLayout showSidebar={true} showFooter={false} hideNavbar={true} hideTopBar={true}>
      <PageHeader
        title={t('title')}
        subtitle={t('subtitle')}
        rightActions={
          <Button onClick={() => setCreateDialogOpen(true)} size="sm">
            <Plus className="h-4 w-4 mr-2" />
            {t('create_reminder')}
          </Button>
        }
      />
      <PageContainer>
        {/* Reminders List */}
        <Suspense fallback={<PageLoading translationKey="loading" />}>
          <RemindersList key={refreshTrigger} />
        </Suspense>

        {/* Create Reminder Dialog */}
        {createDialogOpen && (
          <Suspense fallback={null}>
            <CreateReminderDialog
              open={createDialogOpen}
              onOpenChange={setCreateDialogOpen}
              onSuccess={handleReminderCreated}
            />
          </Suspense>
        )}
      </PageContainer>
    </AppLayout>
  )
}

