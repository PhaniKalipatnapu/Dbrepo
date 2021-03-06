/****** Object:  StoredProcedure [dbo].[ICAS_RETRIEVE_S30]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ICAS_RETRIEVE_S30] (
 @An_Case_IDNO   NUMERIC(6, 0),
 @Ac_Reason_CODE CHAR(5)
 )
AS
 /*
  *     PROCEDURE NAME    : ICAS_RETRIEVE_S30
  *     DESCRIPTION       : To Retrive ISIN State List for Referral Types.For Referral Type's from REFM ISIN/REFL
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 04-OCT-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Lc_StatusOpen_CODE CHAR(1)='O';

  SELECT DISTINCT b.StateFips_CODE,
         b.State_NAME
    FROM ICAS_Y1 a
         JOIN STAT_Y1 b
          ON a.IVDOutOfStateFips_CODE = b.StateFips_CODE
   WHERE a.Case_IDNO = @An_Case_IDNO
     AND a.Reason_CODE = @Ac_Reason_CODE
     AND a.Status_CODE = @Lc_StatusOpen_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of ICAS_RETRIEVE_S30

GO
