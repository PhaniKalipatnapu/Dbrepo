/****** Object:  StoredProcedure [dbo].[FCSOR_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[FCSOR_RETRIEVE_S1](
 @An_Case_IDNO                   NUMERIC(6, 0),
 @An_Record_NUMB                 NUMERIC(22, 0),
 @An_OrderSeq_NUMB               NUMERIC(3, 0) OUTPUT,
 @Ad_OrderEntered_DATE           DATE OUTPUT,
 @An_ArrearsOrdered_AMNT         NUMERIC(11, 2) OUTPUT,
 @Ac_OrderFrequency_CODE         CHAR(4) OUTPUT,
 @Ac_PfaOrder_INDC               CHAR(1) OUTPUT,
 @Ad_Court_DATE                  DATE OUTPUT,
 @Ac_OrderType_CODE              CHAR(4) OUTPUT,
 @Ac_PaymentType_CODE            CHAR(4) OUTPUT,
 @Ac_ApPfa_INDC                  CHAR(1) OUTPUT,
 @Ad_Start_DATE                  DATE OUTPUT,
 @Ad_End_DATE                    DATE OUTPUT,
 @Ad_Mail_DATE                   DATE OUTPUT,
 @Ac_OriginatingState_CODE       CHAR(2) OUTPUT,
 @Ac_CourtOfficial_TEXT          CHAR(24) OUTPUT,
 @Ac_CourtOrderMethod_CODE       CHAR(2) OUTPUT,
 @Ac_CourtOrderEnteredBy_CODE    CHAR(4) OUTPUT,
 @Ac_SpousalSupport_INDC         CHAR(1) OUTPUT,
 @Ac_HealthInsuranceOrdered_INDC CHAR(1) OUTPUT,
 @Ac_InsuranceProvidedBy_CODE    CHAR(4) OUTPUT,
 @Ac_OrderDeviation_CODE         CHAR(1) OUTPUT,
 @As_OrderNotes_TEXT             VARCHAR(2000) OUTPUT,
 @An_RowCount_NUMB               NUMERIC(6, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : FCSOR_RETRIEVE_S1
  *     DESCRIPTION       : Retrieves the frozen case support order details for a given case.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 05-18-2012
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @An_OrderSeq_NUMB = A.OrderSeq_NUMB,
         @Ad_OrderEntered_DATE = A.OrderEntered_DATE,
         @An_ArrearsOrdered_AMNT = A.ArrearsOrdered_AMNT,
         @Ac_OrderFrequency_CODE = A.OrderFrequency_CODE,
         @Ac_PfaOrder_INDC = A.PfaOrder_INDC,
         @Ad_Court_DATE = A.Court_DATE,
         @Ac_OrderType_CODE = A.OrderType_CODE,
         @Ac_PaymentType_CODE = A.PaymentType_CODE,
         @Ac_ApPfa_INDC = A.ApPfa_INDC,
         @Ad_Start_DATE = A.Start_DATE,
         @Ad_End_DATE = A.End_DATE,
         @Ad_Mail_DATE = A.Mail_DATE,
         @Ac_OriginatingState_CODE = A.OriginatingState_CODE,
         @Ac_CourtOfficial_TEXT = A.CourtOfficial_TEXT,
         @Ac_CourtOrderMethod_CODE = A.CourtOrderMethod_CODE,
         @Ac_CourtOrderEnteredBy_CODE = A.CourtOrderEnteredBy_CODE,
         @Ac_SpousalSupport_INDC = SpousalSupport_INDC,
         @Ac_HealthInsuranceOrdered_INDC = A.HealthInsuranceOrdered_INDC,
         @Ac_InsuranceProvidedBy_CODE = A.InsuranceProvidedBy_CODE,
         @Ac_OrderDeviation_CODE = A.OrderDeviation_CODE,
         @As_OrderNotes_TEXT = A.OrderNotes_TEXT,
         @An_RowCount_NUMB = RowCount_NUMB
    FROM (SELECT f.OrderSeq_NUMB,
                 f.OrderEntered_DATE,
                 f.ArrearsOrdered_AMNT,
                 f.OrderFrequency_CODE,
                 f.PfaOrder_INDC,
                 f.Court_DATE,
                 f.OrderType_CODE,
                 f.PaymentType_CODE,
                 f.ApPfa_INDC,
                 f.Start_DATE,
                 f.End_DATE,
                 f.Mail_DATE,
                 f.OriginatingState_CODE,
                 f.CourtOfficial_TEXT,
                 f.CourtOrderMethod_CODE,
                 f.CourtOrderEnteredBy_CODE,
                 f.SpousalSupport_INDC,
                 f.HealthInsuranceOrdered_INDC,
                 f.InsuranceProvidedBy_CODE,
                 f.OrderDeviation_CODE,
                 f.OrderNotes_TEXT,
                 COUNT(1) OVER() AS RowCount_NUMB,
                 ROW_NUMBER() OVER( ORDER BY f.OrderEntered_DATE DESC ) AS ROWNUM
            FROM FCSOR_Y1 f
           WHERE f.Case_IDNO = @An_Case_IDNO) AS A
   WHERE A.ROWNUM = @An_Record_NUMB;
 END;


GO
