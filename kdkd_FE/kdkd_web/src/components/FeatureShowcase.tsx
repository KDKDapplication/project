import phoneGridGif from "../assets/images/Phone Grid Showcase _ Diagonal (4).gif";
import phoneVerticalGif from "../assets/images/Phone Grid Showcase _ Vertical.gif";

interface FeatureShowcaseProps {
  isMobile: boolean;
}

export default function FeatureShowcase({ isMobile }: FeatureShowcaseProps) {
  return (
    <main style={{ maxWidth: 1200, margin: "0 auto", padding: "0 1rem" }}>
      <div>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "5rem",
            flexDirection: isMobile ? "column" : "row",
            gap: isMobile ? "2rem" : "0",
          }}
        >
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              flex: isMobile ? "none" : "1",
              height: isMobile ? "auto" : "295px",
              textAlign: isMobile ? "center" : "left",
            }}
          >
            <p
              className="fade-up"
              style={{
                fontSize: isMobile ? "28px" : "36px",
                color: "#007AFF",
                letterSpacing: "-1px",
                fontWeight: "bold",
              }}
            >
              태깅으로 간편한 송금
            </p>
            <p
              className="fade-up"
              style={{
                letterSpacing: "-1px",
                fontSize: isMobile ? "14px" : "24px",
                color: "#454545",
              }}
            >
              직관적이고 빠른 가족 간 송금 <br />
              복잡한 계좌번호 입력 없이 태그만으로 즉시 전송
            </p>
          </div>
          <div style={{ position: "relative", width: 640, height: 360 }}>
            <img
              className="fade-up"
              src={phoneGridGif}
              alt="Phone Grid Showcase"
              style={{
                display: "block",
                width: 640,
                height: 360,
              }}
            />
            <div
              className="fade-up"
              style={{
                position: "absolute",
                bottom: "0",
                right: "0",
                width: "170px",
                height: "40px",
                backgroundColor: "#F5F8FF",
              }}
            />
          </div>
        </div>

        <div style={{ marginTop: "20rem" }}></div>

        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: "5rem",
            flexDirection: isMobile ? "column" : "row",
            gap: isMobile ? "2rem" : "0",
          }}
        >
          <div
            style={{
              position: "relative",
              width: 640,
              height: 360,
              order: isMobile ? 2 : 1,
            }}
          >
            <img
              className="fade-up"
              src={phoneVerticalGif}
              alt="Phone Vertical Showcase"
              style={{
                display: "block",
                width: 640,
                height: 360,
              }}
            />
            <div
              className="fade-up"
              style={{
                position: "absolute",
                bottom: "0",
                right: "0",
                width: "170px",
                height: "40px",
                backgroundColor: "#F5F8FF",
              }}
            />
          </div>
          <div
            style={{
              display: "flex",
              flexDirection: "column",
              flex: isMobile ? "none" : "1",
              height: isMobile ? "auto" : "295px",
              textAlign: isMobile ? "center" : "right",
              order: isMobile ? 1 : 2,
            }}
          >
            <p
              className="fade-up"
              style={{
                fontSize: isMobile ? "28px" : "36px",
                color: "#007AFF",
                letterSpacing: "-1px",
                fontWeight: "bold",
              }}
            >
              QR 결제
            </p>
            <p
              className="fade-up"
              style={{
                letterSpacing: "-1px",
                fontSize: isMobile ? "14px" : "24px",
                color: "#454545",
              }}
            >
              청소년 전용 QR 코드 결제 시스템 <br />
              실시간 부모 알림 및 잔액 확인
              <br />
              안전하고 투명한 소비 관리
            </p>
          </div>
        </div>
      </div>
    </main>
  );
}
