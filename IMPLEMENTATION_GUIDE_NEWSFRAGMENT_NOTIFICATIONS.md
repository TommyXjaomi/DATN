# Hướng Dẫn Thực Hiện NewsFragment - Hiển Thị Thông Báo

## 📌 Tóm Tắt

Tài liệu này cung cấp hướng dẫn step-by-step để xây dựng NewsFragment hiển thị thông báo từ Notification Service.

---

## 🎯 Mục Tiêu

- Hiển thị danh sách thông báo của người dùng
- Đánh dấu thông báo là đã đọc
- Xóa thông báo
- Hỗ trợ pagination
- (Optional) Real-time notification updates

---

## 📋 Step 1: Tạo Model Classes

### 1.1 Notification Model
Tạo file: `ieltsapp/app/src/main/java/com/example/ieltsapp/model/Notification.java`

```java
package com.example.ieltsapp.model;

import com.google.gson.annotations.SerializedName;
import java.util.Map;

public class Notification {
    @SerializedName("id")
    private String id;
    
    @SerializedName("type")
    private String type;  // achievement, reminder, course_update, exercise_graded, system, social
    
    @SerializedName("category")
    private String category;  // info, success, warning, alert
    
    @SerializedName("title")
    private String title;
    
    @SerializedName("message")
    private String message;
    
    @SerializedName("action_type")
    private String actionType;
    
    @SerializedName("action_data")
    private Map<String, Object> actionData;
    
    @SerializedName("icon_url")
    private String iconUrl;
    
    @SerializedName("image_url")
    private String imageUrl;
    
    @SerializedName("is_read")
    private boolean isRead;
    
    @SerializedName("read_at")
    private String readAt;
    
    @SerializedName("created_at")
    private String createdAt;

    // Constructors
    public Notification() {}

    public Notification(String id, String type, String category, String title, 
                       String message, boolean isRead, String createdAt) {
        this.id = id;
        this.type = type;
        this.category = category;
        this.title = title;
        this.message = message;
        this.isRead = isRead;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getActionType() { return actionType; }
    public void setActionType(String actionType) { this.actionType = actionType; }

    public Map<String, Object> getActionData() { return actionData; }
    public void setActionData(Map<String, Object> actionData) { this.actionData = actionData; }

    public String getIconUrl() { return iconUrl; }
    public void setIconUrl(String iconUrl) { this.iconUrl = iconUrl; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public String getReadAt() { return readAt; }
    public void setReadAt(String readAt) { this.readAt = readAt; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
```

### 1.2 NotificationResponse Model
Tạo file: `ieltsapp/app/src/main/java/com/example/ieltsapp/model/NotificationResponse.java`

```java
package com.example.ieltsapp.model;

import com.google.gson.annotations.SerializedName;
import java.util.List;

public class NotificationResponse {
    @SerializedName("notifications")
    private List<Notification> notifications;
    
    @SerializedName("pagination")
    private PaginationInfo pagination;

    // Constructors
    public NotificationResponse() {}

    public NotificationResponse(List<Notification> notifications, PaginationInfo pagination) {
        this.notifications = notifications;
        this.pagination = pagination;
    }

    // Getters and Setters
    public List<Notification> getNotifications() { return notifications; }
    public void setNotifications(List<Notification> notifications) { this.notifications = notifications; }

    public PaginationInfo getPagination() { return pagination; }
    public void setPagination(PaginationInfo pagination) { this.pagination = pagination; }

    public static class PaginationInfo {
        @SerializedName("page")
        private int page;
        
        @SerializedName("limit")
        private int limit;
        
        @SerializedName("total")
        private int total;
        
        @SerializedName("total_pages")
        private int totalPages;

        public int getPage() { return page; }
        public void setPage(int page) { this.page = page; }

        public int getLimit() { return limit; }
        public void setLimit(int limit) { this.limit = limit; }

        public int getTotal() { return total; }
        public void setTotal(int total) { this.total = total; }

        public int getTotalPages() { return totalPages; }
        public void setTotalPages(int totalPages) { this.totalPages = totalPages; }
    }
}
```

### 1.3 UnreadCountResponse Model
Tạo file: `ieltsapp/app/src/main/java/com/example/ieltsapp/model/UnreadCountResponse.java`

```java
package com.example.ieltsapp.model;

import com.google.gson.annotations.SerializedName;

public class UnreadCountResponse {
    @SerializedName("unread_count")
    private int unreadCount;

    public UnreadCountResponse() {}

    public UnreadCountResponse(int unreadCount) {
        this.unreadCount = unreadCount;
    }

    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }
}
```

---

## 🔗 Step 2: Tạo Network Service

### 2.1 NotificationApiService Interface
Tạo file: `ieltsapp/app/src/main/java/com/example/ieltsapp/network/NotificationApiService.java`

```java
package com.example.ieltsapp.network;

import com.example.ieltsapp.model.Notification;
import com.example.ieltsapp.model.NotificationResponse;
import com.example.ieltsapp.model.UnreadCountResponse;

import retrofit2.Call;
import retrofit2.http.DELETE;
import retrofit2.http.GET;
import retrofit2.http.PUT;
import retrofit2.http.Path;
import retrofit2.http.Query;

public interface NotificationApiService {
    
    /**
     * Lấy danh sách thông báo
     */
    @GET("notifications")
    Call<NotificationResponse> getNotifications(
        @Query("page") int page,
        @Query("limit") int limit,
        @Query("is_read") Boolean isRead,
        @Query("type") String type,
        @Query("category") String category,
        @Query("sort_by") String sortBy,
        @Query("sort_order") String sortOrder,
        @Query("date_from") String dateFrom,
        @Query("date_to") String dateTo
    );
    
    /**
     * Lấy danh sách thông báo (overload - simple)
     */
    @GET("notifications")
    Call<NotificationResponse> getNotifications(
        @Query("page") int page,
        @Query("limit") int limit
    );
    
    /**
     * Lấy số lượng thông báo chưa đọc
     */
    @GET("notifications/unread-count")
    Call<UnreadCountResponse> getUnreadCount();
    
    /**
     * Lấy chi tiết một thông báo
     */
    @GET("notifications/{id}")
    Call<Notification> getNotificationById(@Path("id") String id);
    
    /**
     * Đánh dấu thông báo là đã đọc
     */
    @PUT("notifications/{id}/read")
    Call<Notification> markAsRead(@Path("id") String id);
    
    /**
     * Đánh dấu tất cả thông báo là đã đọc
     */
    @PUT("notifications/mark-all-read")
    Call<MarkAllReadResponse> markAllAsRead();
    
    /**
     * Xóa thông báo
     */
    @DELETE("notifications/{id}")
    Call<Void> deleteNotification(@Path("id") String id);
    
    // Model cho MarkAllReadResponse
    class MarkAllReadResponse {
        public int marked_count;
    }
}
```

### 2.2 Cập nhật ApiClient
Chỉnh sửa: `ieltsapp/app/src/main/java/com/example/ieltsapp/network/ApiClient.java`

Thêm vào phần định nghĩa base URL:
```java
private static final String NOTIFICATION_SERVICE_URL = "http://" + baseIp + ":8086/api/v1/";
```

Thêm method mới vào class:
```java
public static NotificationApiService getNotificationService() {
    return getClient(NOTIFICATION_SERVICE_URL).create(NotificationApiService.class);
}
```

---

## 🎨 Step 3: Tạo Layout Files

### 3.1 Cập nhật fragment_news.xml
Chỉnh sửa: `ieltsapp/app/src/main/res/layout/fragment_news.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="@color/colorBackground">

    <!-- Header -->
    <LinearLayout
        android:id="@+id/headerLayout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:padding="16dp"
        android:gravity="center_vertical">

        <TextView
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="Thông Báo"
            android:textSize="24sp"
            android:textColor="@color/colorPrimary"
            android:textStyle="bold" />

        <TextView
            android:id="@+id/unreadBadge"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:background="@drawable/badge_background"
            android:textColor="@android:color/white"
            android:textSize="12sp"
            android:paddingHorizontal="8dp"
            android:paddingVertical="4dp"
            android:visibility="gone" />
    </LinearLayout>

    <!-- Filter Buttons -->
    <HorizontalScrollView
        android:id="@+id/filterScroll"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_below="@id/headerLayout"
        android:scrollbars="none"
        android:padding="8dp">

        <LinearLayout
            android:id="@+id/filterContainer"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:orientation="horizontal"
            android:gravity="center_vertical" />
    </HorizontalScrollView>

    <!-- RecyclerView -->
    <androidx.recyclerview.widget.RecyclerView
        android:id="@+id/notificationRecyclerView"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_below="@id/filterScroll"
        android:layout_above="@id/loadingLayout" />

    <!-- Loading Layout -->
    <LinearLayout
        android:id="@+id/loadingLayout"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_alignParentBottom="true"
        android:orientation="vertical"
        android:gravity="center"
        android:padding="16dp"
        android:visibility="gone">

        <ProgressBar
            android:layout_width="30dp"
            android:layout_height="30dp"
            android:indeterminate="true"
            android:indeterminateTint="@color/colorPrimary" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Đang tải..."
            android:textSize="14sp"
            android:layout_marginTop="8dp" />
    </LinearLayout>

    <!-- Empty State -->
    <LinearLayout
        android:id="@+id/emptyStateLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_below="@id/filterScroll"
        android:orientation="vertical"
        android:gravity="center"
        android:visibility="gone">

        <ImageView
            android:layout_width="100dp"
            android:layout_height="100dp"
            android:src="@drawable/ic_notifications_none"
            android:contentDescription="@string/no_notifications"
            android:tint="@color/colorAccent"
            android:scaleType="fitCenter" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/no_notifications"
            android:textSize="18sp"
            android:textColor="@color/colorPrimary"
            android:layout_marginTop="16dp" />

        <TextView
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/no_notifications_desc"
            android:textSize="14sp"
            android:textColor="@color/colorHint"
            android:layout_marginTop="8dp"
            android:gravity="center" />
    </LinearLayout>

    <!-- Error Layout -->
    <LinearLayout
        android:id="@+id/errorLayout"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:layout_below="@id/filterScroll"
        android:orientation="vertical"
        android:gravity="center"
        android:visibility="gone">

        <ImageView
            android:layout_width="100dp"
            android:layout_height="100dp"
            android:src="@drawable/ic_error"
            android:contentDescription="@string/error"
            android:tint="@color/colorError"
            android:scaleType="fitCenter" />

        <TextView
            android:id="@+id/errorMessage"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/error_loading_notifications"
            android:textSize="18sp"
            android:textColor="@color/colorError"
            android:layout_marginTop="16dp" />

        <Button
            android:id="@+id/retryButton"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="@string/retry"
            android:layout_marginTop="16dp" />
    </LinearLayout>

</RelativeLayout>
```

### 3.2 Tạo Notification Item Layout
Tạo file: `ieltsapp/app/src/main/res/layout/item_notification.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:padding="12dp"
    android:gravity="center_vertical"
    android:background="?attr/selectableItemBackground">

    <!-- Icon -->
    <ImageView
        android:id="@+id/notificationIcon"
        android:layout_width="48dp"
        android:layout_height="48dp"
        android:contentDescription="@string/notification_icon"
        android:scaleType="fitCenter"
        android:src="@drawable/ic_notifications"
        android:tint="@color/colorPrimary" />

    <!-- Content -->
    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:orientation="vertical"
        android:layout_marginHorizontal="12dp">

        <!-- Title -->
        <TextView
            android:id="@+id/notificationTitle"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Tiêu đề"
            android:textSize="16sp"
            android:textColor="@color/colorPrimary"
            android:textStyle="bold"
            android:maxLines="1"
            android:ellipsize="end" />

        <!-- Message -->
        <TextView
            android:id="@+id/notificationMessage"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="Nội dung chi tiết"
            android:textSize="14sp"
            android:textColor="@color/colorText"
            android:maxLines="2"
            android:ellipsize="end"
            android:layout_marginTop="4dp" />

        <!-- Timestamp -->
        <TextView
            android:id="@+id/notificationTime"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:text="1 giờ trước"
            android:textSize="12sp"
            android:textColor="@color/colorHint"
            android:layout_marginTop="4dp" />
    </LinearLayout>

    <!-- Unread Indicator -->
    <View
        android:id="@+id/unreadDot"
        android:layout_width="8dp"
        android:layout_height="8dp"
        android:background="@drawable/circle_unread"
        android:layout_marginEnd="8dp" />

    <!-- Delete Button -->
    <ImageButton
        android:id="@+id/deleteButton"
        android:layout_width="36dp"
        android:layout_height="36dp"
        android:src="@drawable/ic_delete"
        android:background="?attr/selectableItemBackgroundBorderless"
        android:contentDescription="@string/delete_notification"
        android:tint="@color/colorError"
        android:scaleType="fitCenter" />

</LinearLayout>
```

### 3.3 Drawable Resources
Tạo file: `ieltsapp/app/src/main/res/drawable/circle_unread.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorPrimary" />
</shape>
```

Tạo file: `ieltsapp/app/src/main/res/drawable/badge_background.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="@color/colorError" />
</shape>
```

---

## 📊 Step 4: Tạo Adapter

### 4.1 NotificationAdapter
Tạo file: `ieltsapp/app/src/main/java/com/example/ieltsapp/Adapter/NotificationAdapter.java`

```java
package com.example.ieltsapp.Adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ieltsapp.R;
import com.example.ieltsapp.model.Notification;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class NotificationAdapter extends RecyclerView.Adapter<NotificationAdapter.NotificationViewHolder> {

    private List<Notification> notifications;
    private Context context;
    private OnNotificationClickListener listener;
    private OnNotificationDeleteListener deleteListener;

    public interface OnNotificationClickListener {
        void onNotificationClick(Notification notification);
    }

    public interface OnNotificationDeleteListener {
        void onNotificationDelete(String notificationId, int position);
    }

    public NotificationAdapter(Context context, List<Notification> notifications,
                               OnNotificationClickListener listener,
                               OnNotificationDeleteListener deleteListener) {
        this.context = context;
        this.notifications = notifications;
        this.listener = listener;
        this.deleteListener = deleteListener;
    }

    @NonNull
    @Override
    public NotificationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(context).inflate(R.layout.item_notification, parent, false);
        return new NotificationViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull NotificationViewHolder holder, int position) {
        Notification notification = notifications.get(position);
        
        // Set title
        holder.titleTv.setText(notification.getTitle());
        
        // Set message
        holder.messageTv.setText(notification.getMessage());
        
        // Set timestamp
        holder.timeTv.setText(getRelativeTime(notification.getCreatedAt()));
        
        // Set unread indicator
        if (!notification.isRead()) {
            holder.unreadDot.setVisibility(View.VISIBLE);
        } else {
            holder.unreadDot.setVisibility(View.GONE);
        }
        
        // Set icon based on notification type
        setIconByType(holder.iconIv, notification.getType(), notification.getCategory());
        
        // Load image if available
        if (notification.getImageUrl() != null && !notification.getImageUrl().isEmpty()) {
            Glide.with(context)
                    .load(notification.getImageUrl())
                    .placeholder(R.drawable.placeholder)
                    .error(R.drawable.error_placeholder)
                    .into(holder.iconIv);
        }
        
        // Click listener
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) {
                listener.onNotificationClick(notification);
            }
        });
        
        // Delete button listener
        holder.deleteBtn.setOnClickListener(v -> {
            if (deleteListener != null) {
                deleteListener.onNotificationDelete(notification.getId(), position);
            }
        });
    }

    @Override
    public int getItemCount() {
        return notifications.size();
    }

    public void addNotification(Notification notification) {
        notifications.add(0, notification);
        notifyItemInserted(0);
    }

    public void removeNotification(int position) {
        notifications.remove(position);
        notifyItemRemoved(position);
    }

    public void updateNotification(int position, Notification notification) {
        notifications.set(position, notification);
        notifyItemChanged(position);
    }

    public void clear() {
        notifications.clear();
        notifyDataSetChanged();
    }

    public void addAll(List<Notification> newNotifications) {
        notifications.addAll(newNotifications);
        notifyDataSetChanged();
    }

    private String getRelativeTime(String isoTime) {
        try {
            SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault());
            Date date = isoFormat.parse(isoTime);
            long diffMs = System.currentTimeMillis() - date.getTime();
            long diffSecs = diffMs / 1000;
            long diffMins = diffSecs / 60;
            long diffHours = diffMins / 60;
            long diffDays = diffHours / 24;

            if (diffSecs < 60) {
                return "Vừa xong";
            } else if (diffMins < 60) {
                return diffMins + " phút trước";
            } else if (diffHours < 24) {
                return diffHours + " giờ trước";
            } else if (diffDays < 7) {
                return diffDays + " ngày trước";
            } else {
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy", Locale.getDefault());
                return dateFormat.format(date);
            }
        } catch (Exception e) {
            return "Gần đây";
        }
    }

    private void setIconByType(ImageView imageView, String type, String category) {
        int iconResId = R.drawable.ic_notifications;
        
        if (type != null) {
            switch (type) {
                case "achievement":
                    iconResId = R.drawable.ic_achievement;
                    break;
                case "reminder":
                    iconResId = R.drawable.ic_reminder;
                    break;
                case "course_update":
                    iconResId = R.drawable.ic_course;
                    break;
                case "exercise_graded":
                    iconResId = R.drawable.ic_check;
                    break;
                case "system":
                    iconResId = R.drawable.ic_system;
                    break;
                case "social":
                    iconResId = R.drawable.ic_social;
                    break;
            }
        }
        
        imageView.setImageResource(iconResId);
    }

    static class NotificationViewHolder extends RecyclerView.ViewHolder {
        ImageView iconIv;
        TextView titleTv;
        TextView messageTv;
        TextView timeTv;
        View unreadDot;
        ImageButton deleteBtn;

        NotificationViewHolder(@NonNull View itemView) {
            super(itemView);
            iconIv = itemView.findViewById(R.id.notificationIcon);
            titleTv = itemView.findViewById(R.id.notificationTitle);
            messageTv = itemView.findViewById(R.id.notificationMessage);
            timeTv = itemView.findViewById(R.id.notificationTime);
            unreadDot = itemView.findViewById(R.id.unreadDot);
            deleteBtn = itemView.findViewById(R.id.deleteButton);
        }
    }
}
```

---

## 🎯 Step 5: Implement NewsFragment

### 5.1 NewsFragment Logic
Chỉnh sửa: `ieltsapp/app/src/main/java/com/example/ieltsapp/ui/menu/NewsFragment.java`

```java
package com.example.ieltsapp.ui.menu;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.example.ieltsapp.Adapter.NotificationAdapter;
import com.example.ieltsapp.R;
import com.example.ieltsapp.model.Notification;
import com.example.ieltsapp.model.NotificationResponse;
import com.example.ieltsapp.model.UnreadCountResponse;
import com.example.ieltsapp.network.ApiClient;
import com.example.ieltsapp.network.NotificationApiService;

import java.util.ArrayList;
import java.util.List;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class NewsFragment extends Fragment {

    private RecyclerView notificationRecyclerView;
    private SwipeRefreshLayout swipeRefreshLayout;
    private NotificationAdapter notificationAdapter;
    private List<Notification> notifications;
    private NotificationApiService apiService;
    
    // UI Elements
    private LinearLayout loadingLayout;
    private LinearLayout emptyStateLayout;
    private LinearLayout errorLayout;
    private TextView errorMessage;
    private Button retryButton;
    private TextView unreadBadge;
    
    // Pagination
    private int currentPage = 1;
    private int itemsPerPage = 20;
    private int totalPages = 1;
    private boolean isLoading = false;

    public NewsFragment() {
        // Constructor rỗng bắt buộc
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_news, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        
        // Initialize UI elements
        initializeUI(view);
        
        // Setup API service
        apiService = ApiClient.getNotificationService();
        
        // Setup RecyclerView
        setupRecyclerView();
        
        // Setup SwipeRefreshLayout
        setupSwipeRefresh();
        
        // Setup Retry button
        retryButton.setOnClickListener(v -> loadNotifications());
        
        // Load initial data
        loadNotifications();
        
        // Load unread count
        loadUnreadCount();
    }

    private void initializeUI(View view) {
        notificationRecyclerView = view.findViewById(R.id.notificationRecyclerView);
        swipeRefreshLayout = view.findViewById(R.id.swipeRefreshLayout);
        loadingLayout = view.findViewById(R.id.loadingLayout);
        emptyStateLayout = view.findViewById(R.id.emptyStateLayout);
        errorLayout = view.findViewById(R.id.errorLayout);
        errorMessage = view.findViewById(R.id.errorMessage);
        retryButton = view.findViewById(R.id.retryButton);
        unreadBadge = view.findViewById(R.id.unreadBadge);
        
        notifications = new ArrayList<>();
    }

    private void setupRecyclerView() {
        LinearLayoutManager layoutManager = new LinearLayoutManager(getContext());
        notificationRecyclerView.setLayoutManager(layoutManager);
        
        notificationAdapter = new NotificationAdapter(
                getContext(),
                notifications,
                notification -> handleNotificationClick(notification),
                (notificationId, position) -> handleNotificationDelete(notificationId, position)
        );
        
        notificationRecyclerView.setAdapter(notificationAdapter);
        
        // Add pagination scroll listener
        notificationRecyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                
                LinearLayoutManager manager = (LinearLayoutManager) recyclerView.getLayoutManager();
                int lastVisiblePosition = manager.findLastVisibleItemPosition();
                int totalItemCount = notificationAdapter.getItemCount();
                
                // Load more when near the end
                if (lastVisiblePosition >= totalItemCount - 5 && !isLoading && currentPage < totalPages) {
                    loadMoreNotifications();
                }
            }
        });
    }

    private void setupSwipeRefresh() {
        swipeRefreshLayout.setOnRefreshListener(() -> {
            currentPage = 1;
            notifications.clear();
            notificationAdapter.clear();
            loadNotifications();
        });
        swipeRefreshLayout.setColorSchemeResources(R.color.colorPrimary);
    }

    private void loadNotifications() {
        if (isLoading) return;
        
        isLoading = true;
        showLoadingLayout();
        
        Call<NotificationResponse> call = apiService.getNotifications(currentPage, itemsPerPage);
        
        call.enqueue(new Callback<NotificationResponse>() {
            @Override
            public void onResponse(Call<NotificationResponse> call, Response<NotificationResponse> response) {
                isLoading = false;
                swipeRefreshLayout.setRefreshing(false);
                
                if (response.isSuccessful() && response.body() != null) {
                    NotificationResponse notificationResponse = response.body();
                    List<Notification> newNotifications = notificationResponse.getNotifications();
                    
                    if (newNotifications != null && !newNotifications.isEmpty()) {
                        notifications.clear();
                        notifications.addAll(newNotifications);
                        notificationAdapter.clear();
                        notificationAdapter.addAll(newNotifications);
                        
                        if (notificationResponse.getPagination() != null) {
                            totalPages = notificationResponse.getPagination().getTotalPages();
                        }
                        
                        showNotificationLayout();
                    } else {
                        showEmptyStateLayout();
                    }
                } else {
                    showErrorLayout("Lỗi: " + response.code());
                }
            }

            @Override
            public void onFailure(Call<NotificationResponse> call, Throwable t) {
                isLoading = false;
                swipeRefreshLayout.setRefreshing(false);
                showErrorLayout("Lỗi kết nối: " + t.getMessage());
            }
        });
    }

    private void loadMoreNotifications() {
        if (isLoading || currentPage >= totalPages) return;
        
        isLoading = true;
        currentPage++;
        
        Call<NotificationResponse> call = apiService.getNotifications(currentPage, itemsPerPage);
        
        call.enqueue(new Callback<NotificationResponse>() {
            @Override
            public void onResponse(Call<NotificationResponse> call, Response<NotificationResponse> response) {
                isLoading = false;
                
                if (response.isSuccessful() && response.body() != null) {
                    List<Notification> newNotifications = response.body().getNotifications();
                    if (newNotifications != null) {
                        int startPosition = notificationAdapter.getItemCount();
                        notifications.addAll(newNotifications);
                        notificationAdapter.notifyItemRangeInserted(startPosition, newNotifications.size());
                    }
                }
            }

            @Override
            public void onFailure(Call<NotificationResponse> call, Throwable t) {
                isLoading = false;
                currentPage--; // Rollback page number
            }
        });
    }

    private void loadUnreadCount() {
        Call<UnreadCountResponse> call = apiService.getUnreadCount();
        
        call.enqueue(new Callback<UnreadCountResponse>() {
            @Override
            public void onResponse(Call<UnreadCountResponse> call, Response<UnreadCountResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    int unreadCount = response.body().getUnreadCount();
                    if (unreadCount > 0) {
                        unreadBadge.setText(String.valueOf(unreadCount));
                        unreadBadge.setVisibility(View.VISIBLE);
                    } else {
                        unreadBadge.setVisibility(View.GONE);
                    }
                }
            }

            @Override
            public void onFailure(Call<UnreadCountResponse> call, Throwable t) {
                // Silent fail for unread count
            }
        });
    }

    private void handleNotificationClick(Notification notification) {
        // Mark as read if not already read
        if (!notification.isRead()) {
            markAsRead(notification.getId());
        }
        
        // Handle action
        if (notification.getActionType() != null) {
            handleNotificationAction(notification);
        }
    }

    private void handleNotificationDelete(String notificationId, int position) {
        Call<Void> call = apiService.deleteNotification(notificationId);
        
        call.enqueue(new Callback<Void>() {
            @Override
            public void onResponse(Call<Void> call, Response<Void> response) {
                if (response.isSuccessful()) {
                    notificationAdapter.removeNotification(position);
                    Toast.makeText(getContext(), "Đã xóa thông báo", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(getContext(), "Lỗi xóa thông báo", Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onFailure(Call<Void> call, Throwable t) {
                Toast.makeText(getContext(), "Lỗi: " + t.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void markAsRead(String notificationId) {
        Call<Notification> call = apiService.markAsRead(notificationId);
        
        call.enqueue(new Callback<Notification>() {
            @Override
            public void onResponse(Call<Notification> call, Response<Notification> response) {
                if (response.isSuccessful()) {
                    loadUnreadCount(); // Refresh unread count
                }
            }

            @Override
            public void onFailure(Call<Notification> call, Throwable t) {
                // Silent fail
            }
        });
    }

    private void handleNotificationAction(Notification notification) {
        String actionType = notification.getActionType();
        
        if ("navigate_to_course".equals(actionType)) {
            // TODO: Navigate to course screen
        } else if ("navigate_to_exercise".equals(actionType)) {
            // TODO: Navigate to exercise screen
        } else if ("external_link".equals(actionType)) {
            // TODO: Open external link
        }
    }

    private void showLoadingLayout() {
        loadingLayout.setVisibility(View.VISIBLE);
        notificationRecyclerView.setVisibility(View.GONE);
        emptyStateLayout.setVisibility(View.GONE);
        errorLayout.setVisibility(View.GONE);
    }

    private void showNotificationLayout() {
        loadingLayout.setVisibility(View.GONE);
        notificationRecyclerView.setVisibility(View.VISIBLE);
        emptyStateLayout.setVisibility(View.GONE);
        errorLayout.setVisibility(View.GONE);
    }

    private void showEmptyStateLayout() {
        loadingLayout.setVisibility(View.GONE);
        notificationRecyclerView.setVisibility(View.GONE);
        emptyStateLayout.setVisibility(View.VISIBLE);
        errorLayout.setVisibility(View.GONE);
    }

    private void showErrorLayout(String message) {
        loadingLayout.setVisibility(View.GONE);
        notificationRecyclerView.setVisibility(View.GONE);
        emptyStateLayout.setVisibility(View.GONE);
        errorLayout.setVisibility(View.VISIBLE);
        errorMessage.setText(message);
    }
}
```

---

## 📱 Step 6: String Resources

Thêm vào `ieltsapp/app/src/main/res/values/strings.xml`:

```xml
<!-- Notification Strings -->
<string name="no_notifications">Không có thông báo</string>
<string name="no_notifications_desc">Bạn sẽ nhận được thông báo khi có cập nhật mới</string>
<string name="error">Lỗi</string>
<string name="error_loading_notifications">Lỗi khi tải thông báo. Vui lòng thử lại.</string>
<string name="retry">Thử lại</string>
<string name="notification_icon">Biểu tượng thông báo</string>
<string name="delete_notification">Xóa thông báo</string>
```

---

## ✅ Checklist Thực Hiện

- [ ] Tạo Notification model classes
- [ ] Tạo NotificationApiService interface
- [ ] Cập nhật ApiClient với base URL cho Notification Service
- [ ] Tạo/cập nhật layout files
- [ ] Tạo NotificationAdapter
- [ ] Implement NewsFragment logic
- [ ] Thêm string resources
- [ ] Test API endpoints
- [ ] Test UI interactions
- [ ] Fix bugs
- [ ] Add error handling
- [ ] Add loading states
- [ ] Add pagination

---

## 🧪 Testing

### Unit Tests
```java
// Test NotificationAdapter
// Test API responses
// Test data parsing
```

### Integration Tests
```java
// Test API calls
// Test error handling
// Test pagination
```

### UI Tests
```java
// Test RecyclerView display
// Test click handlers
// Test delete functionality
// Test empty state
// Test error state
```

---

## 📌 Ghi Chú Quan Trọng

1. **Authentication**: Đảm bảo JWT token được include trong tất cả requests
2. **Base URL**: Notification Service chạy trên port 8086
3. **Error Handling**: Luôn handle network errors một cách graceful
4. **Loading States**: Hiển thị loading indicator trong khi tải dữ liệu
5. **Empty States**: Hiển thị empty state khi không có thông báo
6. **Pagination**: Support infinite scroll để load thêm thông báo
7. **Real-time** (Optional): Có thể thêm SSE stream cho real-time notifications

---

**Hướng dẫn được tạo**: 28/12/2025
**Version**: 1.0

```

