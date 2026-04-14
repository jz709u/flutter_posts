# Screen Flow Storyboard

## Dependency Graph

```mermaid
graph TD
    subgraph Presentation["Presentation Layer"]
        UI["Screens<br/>PostsScreen<br/>PostDetailScreen<br/>UserScreen"]
        PROV["Providers<br/>postsProvider<br/>postProvider<br/>commentsProvider<br/>userProvider"]
        ROUTER["Router<br/>GoRouter"]
        THEME["Theme<br/>AppTheme"]
    end

    subgraph Data["Data Layer"]
        REPO["Repositories<br/>PostRepositoryImpl<br/>CommentRepositoryImpl<br/>UserRepositoryImpl"]
        CDS["CachedDataSource"]
        RDS["RemoteDataSource"]
        DTOS["DTOs<br/>PostDto / CommentDto / UserDto"]
    end

    subgraph Core["Core"]
        CACHE["InMemoryCache"]
        DIO["DioClient"]
        RESULT["Result"]
    end

    subgraph Domain["Domain Layer"]
        MODELS["Models<br/>Post / Comment / User"]
        IFACE["Repository Interfaces<br/>PostRepository<br/>CommentRepository<br/>UserRepository"]
    end

    UI --> PROV
    UI --> ROUTER
    UI --> THEME
    PROV --> IFACE
    REPO --> CDS
    CDS --> RDS
    CDS --> CACHE
    RDS --> DIO
    RDS --> DTOS
    DTOS --> MODELS
    REPO --> RESULT
    REPO --> IFACE
    REPO --> MODELS
```

---

## Navigation Flow

```mermaid
flowchart TD
    LAUNCH([App Launch]):::entry
    POSTS["① Posts Screen<br/>──────────────<br/>AppBar: Posts<br/>ListView of posts<br/>pull-to-refresh"]:::screen
    DETAIL["② Post Detail Screen<br/>──────────────<br/>Post title + body<br/>Author chip<br/>Comments list"]:::screen
    PROFILE["③ User Profile Screen<br/>──────────────<br/>Name / email / company<br/>Users posts list"]:::screen

    LAUNCH -->|"/ initial route"| POSTS
    POSTS  -->|"tap post"| DETAIL
    DETAIL -->|"tap author chip"| PROFILE
    PROFILE -->|"tap post"| DETAIL

    classDef entry   fill:#F59E0B,color:#1E1B4B,stroke:#F59E0B,font-weight:bold
    classDef screen  fill:#4338CA,color:#fff,stroke:#6366F1
```

---

## Screen Details

```mermaid
flowchart LR
    subgraph S1["① Posts Screen"]
        direction TB
        A1["AppBar: Posts"]
        A2["AsyncValueWidget"]
        A3["RefreshIndicator"]
        A4["ListView.builder<br/>ListTile per post<br/>title 2 lines<br/>subtitle 1 line"]
        A1 --> A2 --> A3 --> A4
    end

    subgraph S2["② Post Detail Screen"]
        direction TB
        B1["AppBar: Post"]
        B2["CustomScrollView"]
        B3["SliverToBoxAdapter<br/>post title<br/>post body<br/>AuthorChip"]
        B4["SliverList.builder<br/>CommentTile per comment"]
        B1 --> B2 --> B3 --> B4
    end

    subgraph S3["③ User Profile Screen"]
        direction TB
        C1["AppBar: Profile"]
        C2["CustomScrollView"]
        C3["SliverToBoxAdapter<br/>name / username<br/>email / website<br/>company"]
        C4["SliverList.builder<br/>ListTile per post"]
        C1 --> C2 --> C3 --> C4
    end

    S1 -->|tap post| S2
    S2 -->|tap author chip| S3
    S3 -->|tap post| S2
```

---

## State & Caching

```mermaid
flowchart LR
    subgraph Providers["Riverpod Providers"]
        P1["postsProvider<br/>AsyncNotifier"]
        P2["postProvider id<br/>FamilyAsyncNotifier"]
        P3["commentsProvider id<br/>FamilyAsyncNotifier"]
        P4["userProvider id<br/>FamilyAsyncNotifier"]
        P5["postsByUserProvider id<br/>FamilyAsyncNotifier"]
    end

    subgraph Cache["InMemoryCache TTL"]
        C1["all_posts - 3 min"]
        C2["post_id - 10 min"]
        C3["user_posts_id - 5 min"]
        C4["user_id - 30 min"]
        C5["comments - not cached"]
    end

    P1 --> C1
    P2 --> C2
    P3 --> C5
    P4 --> C4
    P5 --> C3
```

---

## Route Map

```mermaid
flowchart LR
    R1["/<br/>PostsScreen"]
    R2["/posts/:postId<br/>PostDetailScreen"]
    R3["/users/:userId<br/>UserScreen"]

    R1 -->|"goNamed post-detail"| R2
    R2 -->|"goNamed user-profile"| R3
    R3 -->|"goNamed post-detail"| R2
```
