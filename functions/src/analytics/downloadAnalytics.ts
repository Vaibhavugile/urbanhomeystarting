import * as admin from "firebase-admin";
import {onRequest} from "firebase-functions/v2/https";
import {FieldValue} from "firebase-admin/firestore";

export const logDownloadAnalytics = onRequest(
  {
    cors: true,
  },
  async (req, res) => {
    try {
      if (req.method !== "POST") {
        res.status(405).json({
          success: false,
          message: "Method Not Allowed",
        });
        return;
      }

      const data = req.body;

      const {
        sessionId,
        device,
        os,
        browser,
        platform,
        campaign,
        utmSource,
        utmMedium,
        utmCampaign,
        utmContent,
        isFirstVisit,
        language,
        timezone,
        userAgent,
        cookieEnabled,
        online,
        touchSupport,
        screenWidth,
        screenHeight,
        viewportWidth,
        viewportHeight,
        orientation,
        colorDepth,
        pixelRatio,
        networkType,
        downlink,
        pageTitle,
        hostname,
        pathname,
        url,
        referrer,
        clientTimestamp,
      } = data;

      // --------------------------------
      // Update stats (first visit only)
      // --------------------------------

      if (isFirstVisit) {
        const statsRef = admin
          .firestore()
          .collection("downloadAnalytics")
          .doc("stats");

        const updateData: Record<string, unknown> = {
          total: FieldValue.increment(1),
          lastVisit: FieldValue.serverTimestamp(),
        };

        if (device) {
          updateData[device] = FieldValue.increment(1);
        }

        if (platform) {
          updateData[platform] = FieldValue.increment(1);
        }

        if (browser) {
          updateData[browser.toLowerCase()] =
            FieldValue.increment(1);
        }

        await statsRef.set(updateData, {
          merge: true,
        });
      }

      // --------------------------------
      // Create visit log
      // --------------------------------

      await admin
        .firestore()
        .collection("downloadLogs")
        .add({
          sessionId,

          device,
          os,
          browser,
          platform,

          campaign,

          utmSource,
          utmMedium,
          utmCampaign,
          utmContent,

          isFirstVisit,

          language,
          timezone,

          userAgent,

          cookieEnabled,
          online,
          touchSupport,

          screenWidth,
          screenHeight,

          viewportWidth,
          viewportHeight,

          orientation,
          colorDepth,
          pixelRatio,

          networkType,
          downlink,

          pageTitle,

          hostname,
          pathname,
          url,

          referrer,

          ip:
            req.headers["x-forwarded-for"] ??
            req.ip ??
            null,

          clientTimestamp,

          serverTimestamp:
            FieldValue.serverTimestamp(),
        });

      res.status(200).json({
        success: true,
      });
    } catch (error) {
      console.error(error);

      res.status(500).json({
        success: false,
        message: "Internal Server Error",
      });
    }
  }
);
