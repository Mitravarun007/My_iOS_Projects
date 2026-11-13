# ExpenseClaims (SwiftUI + SwiftData)

A native iOS expense/bill claims app matching the flow from your reference recording:

**Home → Save Bills (category/currency → capture or upload → on-device receipt
extraction → tag) → My Bills (Unclaimed / Draft / Raised) → Raise Claim (form) →
Submit Claim (summary + confirm).**

## What's inside

- **SwiftUI**, MVVM-ish (lightweight — SwiftData models + `@Query` do most of the
  "ViewModel" work; add dedicated ViewModel types if you want stricter MVVM as
  the app grows).
- **SwiftData** for local persistence (`Bill`, `Claim`, `ClaimTag` models) —
  no backend required to run and test end-to-end.
- **Vision framework** on-device OCR (`ReceiptScannerService`) that reads text
  off a photographed/uploaded receipt and heuristically pulls out vendor name,
  total amount, and date — this stands in for the "GenAI extraction" step,
  fully offline and free.
- **PhotosPicker** + a `UIImagePickerController` camera wrapper for
  capture/upload.

## Project structure

```
ExpenseClaims/
  ExpenseClaimsApp.swift        // App entry + SwiftData ModelContainer
  Models/
    Bill.swift                  // @Model — a single receipt/bill
    Claim.swift                 // @Model — a raised claim (1-to-many bills)
    ClaimTag.swift               // @Model — reusable grouping tag
    ClaimCategory.swift          // Category / status / currency enums
  Services/
    ReceiptScannerService.swift  // Vision OCR + amount/vendor/date heuristics
  Views/
    RootTabView.swift            // Home / My Bills / Notifications tabs
    HomeView.swift
    CategorySelectionView.swift
    BillCaptureView.swift
    CameraCaptureView.swift
    BillReviewView.swift         // extraction + tagging
    MyBillsView.swift
    RaiseClaimView.swift
    SubmitClaimView.swift
    NotificationsView.swift
```

## Setup (5 minutes)

1. In Xcode: **File → New → Project → iOS → App**.
   - Interface: **SwiftUI**, Language: **Swift**
   - Name it `ExpenseClaims`
   - **Minimum deployment target: iOS 17** (required for SwiftData)
2. Delete the default `ContentView.swift` and the auto-generated `...App.swift`.
3. Drag the `ExpenseClaims/` folder from this download into your Xcode project
   navigator (check "Copy items if needed" and "Create groups").
4. Open **Info** tab of your target (or `Info.plist`) and add:
   - `Privacy - Camera Usage Description` → "Used to capture photos of receipts."
   - `Privacy - Photo Library Usage Description` → "Used to upload receipt images."
5. Build & run on a simulator or device (camera capture requires a physical
   device — the simulator will automatically fall back to the photo library).

## Notes / next steps

- **Backend sync**: everything currently persists locally via SwiftData. To
  sync to a server, the cleanest path is adding a thin `SyncService` that
  pushes/pulls `Bill`/`Claim` on save — SwiftData's `ModelContext.save()` is
  already the single choke point to hook into. CloudKit sync is also a
  near-free option since these models are simple value-holders (add
  `.modelContainer(for:isCloudKitEnabled: true)`).
- **OCR accuracy**: `ReceiptScannerService` uses regex + keyword heuristics on
  top of Vision's text recognition. It's solid for clearly-printed receipts;
  for messier ones you'd eventually want an on-device ML classifier or a
  server-side model.
- **Employee attendee picker**: currently a free-text field per your recording
  (`Enter Employee Name`); swap in a real directory-search API when you have
  one to hit.
- **Auth**: no login screen included — plug in your SSO/auth flow ahead of
  `RootTabView` in `ExpenseClaimsApp`.
