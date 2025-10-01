package com.e106.kdkd.invite.controller;

//@Tag(name = "관계 연결 컨트롤러", description = "연결 관계 코드 관련 API 엔드포인트")
//@RestController
//@RequiredArgsConstructor
//@RequestMapping("/invites")
public class InviteController {

//    private final InviteCodeService service;
//
//    // 부모: 코드 발급/재발급 (기존 코드가 있으면 삭제 후 새로 발급)
//    @Operation(summary = "부모 코드 생성 API")
//    @PostMapping("/code")
//    public ResponseEntity<CreateInviteCodeResponse> create(
//        @AuthenticationPrincipal CustomPrincipal principal) {
//        String parentUuid = principal.userUuid();
//        return ResponseEntity.ok(service.createCode(parentUuid, 600L));
//    }
//
//    // 자녀: 코드 사용(1회용) → 부모-자녀 연결
//    @Operation(summary = "부모 코드 입력으로 자녀 등록 API")
//    @PostMapping("/activate")
//    public ResponseEntity<ActivateInviteResponse> activate(@RequestParam String code,
//        @AuthenticationPrincipal CustomPrincipal principal) {
//        String childUuid = principal.userUuid());
//        return ResponseEntity.ok(service.activate(code, childUuid));
//    }
}
