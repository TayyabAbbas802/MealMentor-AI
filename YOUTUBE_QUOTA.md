# YouTube API Quota Management

## ⚠️ Important Change

**Auto-fetch has been DISABLED** to prevent quota exhaustion.

## Problem

YouTube API free tier:
- 10,000 units/day
- Each search = 100 units
- **Only 100 searches per day**

Your app was trying to fetch videos for ALL exercises at once (200+ exercises), which quickly exhausted the quota.

## Solution

Videos are now **opt-in** - fetch only when needed.

### Option 1: Fetch for Specific Exercises Only

```dart
// In your controller
Future<void> loadExercisesWithVideos() async {
  // Get exercises without videos
  final exercises = await wgerService.getExercises();
  
  // Fetch videos for ONLY the first 10 exercises
  final topExercises = exercises.take(10).toList();
  final enriched = await wgerService.enrichExercisesWithVideos(topExercises);
  
  exerciseList.value = enriched;
}
```

### Option 2: Fetch On-Demand (Recommended)

```dart
// Fetch video only when user taps on exercise
Future<void> showExerciseDetail(Map<String, dynamic> exercise) async {
  // Show loading
  isLoading.value = true;
  
  // Fetch video for this ONE exercise
  final enriched = await wgerService.enrichExerciseWithVideo(exercise);
  
  // Show detail screen with video
  Get.to(() => ExerciseDetailScreen(exercise: enriched));
  
  isLoading.value = false;
}
```

### Option 3: Pre-cache Popular Exercises

```dart
// On app start, cache only popular exercises
@override
void onInit() {
  super.onInit();
  _preCachePopularExercises();
}

Future<void> _preCachePopularExercises() async {
  final youtubeService = YouTubeExerciseService();
  await youtubeService.preCachePopularExercises(); // Only 15 exercises
}
```

## Quota Management Tips

1. **Limit searches**: Only fetch videos for exercises user actually views
2. **Cache aggressively**: Store video IDs in local database
3. **Batch wisely**: Fetch max 10-20 videos at a time
4. **Monitor quota**: Check Google Cloud Console daily

## Quota Reset

- Resets at **midnight Pacific Time**
- You'll have 100 searches again tomorrow

## Alternative: Use WGER Images

If you don't want to deal with quotas, just use WGER images:

```dart
// In your exercise list
Image.network(exercise['gifUrl']) // Uses WGER image
```

## Current Status

✅ Auto-fetch disabled
✅ Quota errors handled gracefully  
✅ App won't crash on quota exceeded
⏳ Videos available on-demand only

## Recommended Approach

For your app, I recommend:

1. **Use WGER images** for exercise list (free, unlimited)
2. **Fetch YouTube video** only when user taps exercise detail
3. **Cache video IDs** in local database for future use

This way you'll use ~10-20 API calls per day instead of 200+.
