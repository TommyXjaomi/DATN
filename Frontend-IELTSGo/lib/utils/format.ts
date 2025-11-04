/**
 * Format a number with thousand separators
 */
export function formatNumber(num: number): string {
  return new Intl.NumberFormat("en-US").format(num)
}

/**
 * Format currency
 */
export function formatCurrency(amount: number, currency = "USD"): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
  }).format(amount)
}

/**
 * Format percentage
 */
export function formatPercentage(value: number, decimals = 0): string {
  return `${value.toFixed(decimals)}%`
}

/**
 * Truncate text with ellipsis
 */
export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text
  return text.slice(0, maxLength) + "..."
}

/**
 * Format duration in seconds to readable format
 * Examples:
 * - 3661 seconds → "1h 1m"
 * - 390 seconds → "6m 30s"
 * - 45 seconds → "45s"
 */
export function formatDuration(seconds: number): string {
  // Round to nearest second for consistent display
  const totalSeconds = Math.round(seconds)
  
  const hours = Math.floor(totalSeconds / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)
  const secs = totalSeconds % 60

  if (hours > 0) {
    // Show hours and minutes, round minutes (don't show seconds if > 1 hour)
    return `${hours}h ${minutes}m`
  } else if (minutes > 0) {
    // Show minutes and seconds
    return `${minutes}m ${secs}s`
  } else {
    // Show seconds only
    return `${secs}s`
  }
}

/**
 * Format course duration from hours (database format) to seconds for display
 * Ensures consistent calculation across all components
 * @param durationHours - Duration in hours (from database, e.g., 1.5)
 * @returns Duration in seconds (rounded)
 */
export function formatCourseDuration(durationHours: number | undefined | null): string {
  if (!durationHours || durationHours <= 0) {
    return "0m"
  }
  
  // Convert hours to seconds and round to nearest second
  const seconds = Math.round(durationHours * 3600)
  return formatDuration(seconds)
}

/**
 * Format file size
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return "0 Bytes"

  const k = 1024
  const sizes = ["Bytes", "KB", "MB", "GB"]
  const i = Math.floor(Math.log(bytes) / Math.log(k))

  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + " " + sizes[i]
}
