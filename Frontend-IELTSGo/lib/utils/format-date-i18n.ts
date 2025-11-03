/**
 * Format date to relative time with i18n support
 * Returns translated strings like "1 ngày trước" / "1 day ago"
 */

export function formatRelativeDate(
  date: string | Date,
  t: (key: string, params?: Record<string, string | number>) => string
): string {
  const d = new Date(date)
  const now = new Date()
  const diffInSeconds = Math.floor((now.getTime() - d.getTime()) / 1000)

  if (diffInSeconds < 60) {
    return t('reviews.just_now') || "Vừa xong"
  }

  const diffInMinutes = Math.floor(diffInSeconds / 60)
  if (diffInMinutes < 60) {
    const translated = t('reviews.minutes_ago', { count: diffInMinutes })
    if (translated !== 'reviews.minutes_ago') {
      return translated
    }
    // Fallback
    return `${diffInMinutes} ${diffInMinutes === 1 ? (t('reviews.minute_ago') || 'phút') : (t('reviews.minutes_ago_word') || 'phút')} trước`
  }

  const diffInHours = Math.floor(diffInMinutes / 60)
  if (diffInHours < 24) {
    const translated = t('reviews.hours_ago', { count: diffInHours })
    if (translated !== 'reviews.hours_ago') {
      return translated
    }
    return `${diffInHours} ${diffInHours === 1 ? (t('reviews.hour_ago') || 'giờ') : (t('reviews.hours_ago_word') || 'giờ')} trước`
  }

  const diffInDays = Math.floor(diffInHours / 24)
  if (diffInDays < 7) {
    const translated = t('reviews.days_ago', { count: diffInDays })
    if (translated !== 'reviews.days_ago') {
      return translated
    }
    return `${diffInDays} ${diffInDays === 1 ? (t('reviews.day_ago') || 'ngày') : (t('reviews.days_ago_word') || 'ngày')} trước`
  }

  const diffInWeeks = Math.floor(diffInDays / 7)
  if (diffInWeeks < 4) {
    const translated = t('reviews.weeks_ago', { count: diffInWeeks })
    if (translated !== 'reviews.weeks_ago') {
      return translated
    }
    return `${diffInWeeks} ${diffInWeeks === 1 ? (t('reviews.week_ago') || 'tuần') : (t('reviews.weeks_ago_word') || 'tuần')} trước`
  }

  const diffInMonths = Math.floor(diffInDays / 30)
  if (diffInMonths < 12) {
    const translated = t('reviews.months_ago', { count: diffInMonths })
    if (translated !== 'reviews.months_ago') {
      return translated
    }
    return `${diffInMonths} ${diffInMonths === 1 ? (t('reviews.month_ago') || 'tháng') : (t('reviews.months_ago_word') || 'tháng')} trước`
  }

  const diffInYears = Math.floor(diffInDays / 365)
  const translated = t('reviews.years_ago', { count: diffInYears })
  if (translated !== 'reviews.years_ago') {
    return translated
  }
  return `${diffInYears} ${diffInYears === 1 ? (t('reviews.year_ago') || 'năm') : (t('reviews.years_ago_word') || 'năm')} trước`
}

