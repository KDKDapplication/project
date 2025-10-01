import image1111 from "../assets/images/1111.png";
import image2222 from "../assets/images/2222.png";
import image3333 from "../assets/images/3333.png";

interface ParentSectionProps {
  isMobile: boolean;
}

export default function ParentSection({ isMobile }: ParentSectionProps) {
  return (
    <main style={{ maxWidth: 1200, margin: "0 auto", padding: "0 1rem" }}>
      <div style={{ marginTop: "31rem" }}>
        <p
          className="fade-up"
          style={{
            fontSize: "16px",
            color: "#007AFF",
            letterSpacing: "-1px",
            fontWeight: "extraLight",
          }}
        >
          Parent
        </p>
        <p
          className="fade-up"
          style={{
            fontSize: "36px",
            color: "#007AFF",
            letterSpacing: "-1px",
            fontWeight: "bold",
            paddingBottom: "27px",
          }}
        >
          부모화면→
        </p>
        <div
          style={{
            display: "flex",
            flexDirection: isMobile ? "column" : "row",
            justifyContent: "space-between",
            marginBottom: "650px",
          }}
        >
          <div
            style={{
              order: isMobile ? 1 : 0,
              display: isMobile ? "contents" : "block",
            }}
          >
            <p
              className="fade-up"
              style={{
                fontSize: "38px",
                color: "#454545",
                letterSpacing: "-1px",
                fontWeight: "bold",
                paddingBottom: "42px",
                order: isMobile ? 1 : 0,
              }}
            >
              용돈 계좌를 만들 수 있어요
            </p>
            <p
              className="fade-up"
              style={{
                fontSize: "28px",
                color: "#454545",
                letterSpacing: "-1px",
                paddingBottom: "187px",
                order: isMobile ? 1 : 0,
              }}
            >
              용돈 계좌를 만들 수 있어요 부모님은 자녀의 <br />
              용돈금액을 설정하면 매월 자동이체 돼요. <br />
              자녀의 용돈 잔액과 사용내역을 볼 수 있어요.
            </p>
            <img
              className="fade-up"
              src={image1111}
              alt="1111"
              style={{
                filter:
                  "drop-shadow(-22px 23px 46.9px rgba(158, 158, 158, 0.22))",
                width: "28rem",
                marginBottom: isMobile ? "6rem" : "0",
                order: isMobile ? 4 : 0,
              }}
            />
          </div>
          <div
            style={{
              display: isMobile ? "contents" : "flex",
              flexDirection: "column",
              justifyContent: "space-between",
              height: isMobile ? "auto" : "98rem",
            }}
          >
            <img
              className="fade-up"
              src={image2222}
              alt="2222"
              style={{
                filter:
                  "drop-shadow(-22px 23px 46.9px rgba(158, 158, 158, 0.22))",
                width: "28rem",
                order: isMobile ? 2 : 0,
                marginBottom: isMobile ? "6rem" : "0",
              }}
            />
            <div style={{ order: isMobile ? 3 : 0 }}>
              <p
                className="fade-up"
                style={{
                  fontSize: "38px",
                  color: "#454545",
                  letterSpacing: "-1px",
                  fontWeight: "bold",
                  paddingBottom: "42px",
                  order: isMobile ? 1 : 0,
                }}
              >
                빌리기와 소비를 관리할 수 있어요
              </p>
              <p
                className="fade-up"
                style={{
                  fontSize: "28px",
                  color: "#454545",
                  letterSpacing: "-1px",
                  paddingBottom: "187px",
                  order: isMobile ? 1 : 0,
                }}
              >
                자녀가 돈을 빌린 내역을 확인하고 관리할 수 있어요. <br />
                지도에서 사용처를 확인하고 <br />
                소비 패턴을 분석할 수 있어요.
              </p>
            </div>
          </div>
        </div>
        <div
          style={{
            display: "flex",
            flexDirection: isMobile ? "column" : "row",
            justifyContent: "space-between",
            marginBottom: "650px",
          }}
        >
          <div>
            <p
              className="fade-up"
              style={{
                fontSize: "38px",
                color: "#454545",
                letterSpacing: "-1px",
                fontWeight: "bold",
                paddingBottom: "42px",
                order: isMobile ? 1 : 0,
              }}
            >
              미션을 등록할 수 있어요
            </p>
            <p
              className="fade-up"
              style={{
                fontSize: "28px",
                color: "#454545",
                letterSpacing: "-1px",
                paddingBottom: "187px",
                order: isMobile ? 1 : 0,
              }}
            >
              부모님이 자녀에게 특별한 미션을 등록할 수 있어요. <br />
              미션 설명과 보상을 정해주면, <br />
              자녀가 재미있게 도전하고 성취할 수 있어요.
            </p>
          </div>
          <div
            style={{
              display: "flex",
              flexDirection: isMobile ? "column-reverse" : "column",
            }}
          >
            <img
              src={image3333}
              alt="3333"
              style={{
                filter:
                  "drop-shadow(-22px 23px 46.9px rgba(158, 158, 158, 0.22))",
                width: "28rem",
              }}
            />
          </div>
        </div>
      </div>
    </main>
  );
}
