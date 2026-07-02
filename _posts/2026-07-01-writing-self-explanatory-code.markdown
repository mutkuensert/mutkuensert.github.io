---
layout: post
title:  "Writing self-explanatory code"
date:   2026-07-01 07:00:00 +0300
categories: android
excerpt: ""
---

While refactoring some code, I decided to share my approach that I use to make code easier to understand and reduce the need for developers to dive into the implementation details.

First version of the code:

```java
@Override
public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    ActivityResultLauncher<String> requestPermissionLauncher =
            registerForActivityResult(
                    new ActivityResultContracts.RequestPermission(),
                    granted -> {
                        if (shouldShowIntroduction()) {
                            showIntroduction();
                        }
                    }
            );
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            requireActivity().checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
        requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS);
    } else if (shouldShowIntroduction()) {
        showIntroduction();
    }
}
```

Let’s separate some of the code into different methods.

```java
@Override
public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    requestNotificationPermission();
}

private void requestNotificationPermission() {
    if (!hasNotificationPermission()) {
        ActivityResultLauncher<String> requestPermissionLauncher =
                registerForActivityResult(
                        new ActivityResultContracts.RequestPermission(),
                        granted -> {
                            if (shouldShowIntroduction()) {
                                showIntroduction();
                            }
                        }
                );
        requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS);
    } else if (shouldShowIntroduction()) {
        showIntroduction();
    }
}

private boolean hasNotificationPermission() {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU
            || requireActivity().checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED;
}
```

Now we've done some abstractions by creating the `requestNotificationPermission` and `hasNotificationPermission` methods. But **there is a side effect**. The name `requestNotificationPermission` doesn't indicate whether it will request the permission and show the introduction once the permission flow is complete, or simply show the introduction because the permission has already been granted.

```java
@Override
public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
    super.onViewCreated(view, savedInstanceState);
    requestNotificationPermission((permissionGranted) -> {
        if (shouldShowIntroduction()) {
            showIntroduction();
        }
    });
}

private void requestNotificationPermission(Consumer<Boolean> onCompleted) {
    if (hasNotificationPermission()) {
        onCompleted.accept(true);
    } else {
        ActivityResultLauncher<String> requestPermissionLauncher = createRequestPermissionLauncher(onCompleted);
        requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS);
    }
}

@NonNull
private ActivityResultLauncher<String> createRequestPermissionLauncher(Consumer<Boolean> onCompleted) {
    return registerForActivityResult(new ActivityResultContracts.RequestPermission(), onCompleted::accept);
}

private boolean hasNotificationPermission() {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU
            || requireActivity().checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED;
}
```

Now, by looking at just a couple of lines of code in the `onViewCreated` method, the reader will understand that notification permission will be requested, and once that process is completed, an introduction will be shown if necessary. Of course, it was easy to understand at the first version as well. But this is only an example. Imagine you're trying to understand what some code does in hundreds of lines of code. Ideally, when someone reads a code, they should not need to inspect its internals to understand what it does and they should be able to understand exactly what the code does, not how it does it.