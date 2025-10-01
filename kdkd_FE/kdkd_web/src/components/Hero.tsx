import backgroundImage from "../assets/images/background.png";

interface HeroProps {
  isMobile: boolean;
}

export default function Hero({ isMobile }: HeroProps) {
  return (
    <div
      style={{
        backgroundImage: `url(${backgroundImage})`,
        backgroundSize: "cover",
        backgroundPosition: "top center",
        backgroundRepeat: "no-repeat",
        minHeight: "100vh",
        position: "relative",
      }}
    >
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: "rgba(0, 0, 0, 0.2)",
          zIndex: 1,
        }}
      ></div>
      <main
        style={{
          maxWidth: 1200,
          margin: "0 auto",
          padding: "6rem 1rem 0",
          position: "relative",
          zIndex: 2,
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          minHeight: "100vh",
        }}
      >
        <h1
          style={{
            fontSize: isMobile ? "24px" : "4rem",
            textAlign: "center",
            letterSpacing: "-1px",
            fontWeight: "bold",
            color: "#FFD93D",
          }}
        >
          키득키득에 대해 알아봐요
        </h1>

        <h5
          style={{
            fontSize: isMobile ? "14px" : "2rem",
            textAlign: "center",
            letterSpacing: "-1px",
            fontWeight: "regular",
            color: "#FFD93D",
          }}
        >
          부모와 자녀가 함께 금융 습관을 만들 수 있는 금융앱
        </h5>
      </main>
    </div>
  );
}