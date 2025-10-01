import image4444 from "../assets/images/4444.png";
import image5555 from "../assets/images/5555.png";
import image6666 from "../assets/images/6666.png";
import image7777 from "../assets/images/7777.png";
import image8888 from "../assets/images/8888.png";

interface ChildSectionProps {
  isMobile: boolean;
}

export default function ChildSection({ isMobile }: ChildSectionProps) {
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
          Child
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
          자녀화면→
        </p>
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
              }}
            >
              나의 용돈과 미션을 확인할 수 있어요
            </p>
            <p
              className="fade-up"
              style={{
                fontSize: "28px",
                color: "#454545",
                letterSpacing: "-1px",
                paddingBottom: "187px",
              }}
            >
              용돈 잔액과 해야 할 미션을 <br />
              한눈에 볼 수 있어요. <br />
              미션과 모으기 상자를 꾸준히 수행하면 <br />
              키덕이가 성장해요.
            </p>
          </div>
          <div
            style={{
              display: "flex",
              flexDirection: isMobile ? "column-reverse" : "column",
              justifyContent: "space-between",
            }}
          >
            <img
              className="fade-up"
              src={image7777}
              alt="7777"
              style={{
                filter:
                  "drop-shadow(-22px 23px 46.9px rgba(158, 158, 158, 0.22))",
                width: "28rem",
              }}
            />
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
              모으기 상자
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
              여러 목표별 저축 계좌를 만들 수 있어요. <br />
              용돈이 들어올 때마다 자동 분할 저축으로 <br />
              체계적인 저축 습관을 길러요. 😊
            </p>
            <img
              className="fade-up"
              src={image5555}
              alt="5555"
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
              src={image4444}
              alt="4444"
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
                모으기 상자 상세 화면
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
                목표별 진행률을 확인하며 성취감을 느낄 수 있어요. <br />
                원하는 물건이나 경험을 구체적으로 정하면 <br />
                저축 과정이 더 재미있고 의미있게 다가와요.
              </p>
            </div>
          </div>
        </div>

        <div>
          <div
            style={{
              display: "flex",
              flexDirection: isMobile ? "column" : "row",
              justifyContent: "space-between",
              marginBottom: "650px",
            }}
          >
            <div style={{ order: isMobile ? 1 : 1 }}>
              <p
                className="fade-up"
                style={{
                  fontSize: "38px",
                  color: "#454545",
                  letterSpacing: "-1px",
                  fontWeight: "bold",
                  paddingBottom: "42px",
                  textAlign: isMobile ? "start" : "end",
                }}
              >
                저축할 금액을 미리 설정하세요
              </p>
              <p
                className="fade-up"
                style={{
                  fontSize: "28px",
                  color: "#454545",
                  letterSpacing: "-1px",
                  paddingBottom: "187px",
                  textAlign: isMobile ? "start" : "end",
                }}
              >
                원하는 목표에 맞춰 매달 저축할 금액을 <br />
                미리 정해둘 수 있어요. 꾸준히 모으면서 <br />
                계획적 저축 습관을 기를 수 있습니다.
              </p>
            </div>

            <div style={{ order: isMobile ? 2 : 0 }}>
              <img
                className="fade-up"
                src={image6666}
                alt="6666"
                style={{
                  filter:
                    "drop-shadow(-22px 23px 46.9px rgba(158, 158, 158, 0.44))",
                  width: "28rem",
                }}
              />
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
                }}
              >
                미션기능
              </p>
              <p
                className="fade-up"
                style={{
                  fontSize: "28px",
                  color: "#454545",
                  letterSpacing: "-1px",
                  paddingBottom: "187px",
                }}
              >
                집안일이나 공부 같은 미션을 수행하면 <br />
                보상으로 추가 용돈을 받을 수 있어요. <br />
                미션을 통해 좋은 습관도 기르고 <br />
                재미있게 용돈을 늘려갈 수 있습니다.
              </p>
            </div>
            <div
              style={{
                display: "flex",
                flexDirection: isMobile ? "column-reverse" : "column",
              }}
            >
              <img
                className="fade-up"
                src={image8888}
                alt="8888"
                style={{
                  filter:
                    "drop-shadow(-22px 23px 46.9px rgba(158, 158, 158, 0.22))",
                  width: "28rem",
                }}
              />
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
