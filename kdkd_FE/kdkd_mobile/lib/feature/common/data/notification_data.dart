// class NotificationMockData {
//   static NotificationListResponse getMockNotifications() {
//     return NotificationListResponse(
//       totalPages: 1,
//       alerts: [
//         NotificationItem(
//           alertUuid: "eef34aa6-af0b-4fbd-af4d-72da087ba601",
//           content: "알림테스트",
//           createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
//           senderName: "신유빈",
//         ),
//         NotificationItem(
//           alertUuid: "cdcd4aad-b710-4f7a-bb87-cd87bc1fa398",
//           content: "자녀 홍길동이 등록되었습니다.",
//           createdAt: DateTime.now().subtract(const Duration(hours: 2)),
//           senderName: "홍길동",
//         ),
//         NotificationItem(
//           alertUuid: "abc12345-1234-5678-9abc-def123456789",
//           content: "용돈 5000원이 입금되었습니다.",
//           createdAt: DateTime.now().subtract(const Duration(days: 1)),
//           senderName: "엄마",
//         ),
//         NotificationItem(
//           alertUuid: "def67890-abcd-1234-5678-9012345abcde",
//           content: "저축 목표를 달성했습니다! 축하해요",
//           createdAt: DateTime.now().subtract(const Duration(days: 2)),
//           senderName: "KDKD 시스템",
//         ),
//         NotificationItem(
//           alertUuid: "ghi34567-efgh-5678-90ab-cdef67890123",
//           content: "이번 달 용돈 사용 내역을 확인해보세요.",
//           createdAt: DateTime.now().subtract(const Duration(days: 3)),
//           senderName: "아빠",
//         ),
//       ],
//     );
//   }

//   static NotificationListResponse getEmptyNotifications() {
//     return NotificationListResponse(
//       totalPages: 1,
//       alerts: [],
//     );
//   }
// }
