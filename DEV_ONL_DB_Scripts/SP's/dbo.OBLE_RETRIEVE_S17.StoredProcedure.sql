/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S17]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S17](
 @An_Case_IDNO     NUMERIC(6, 0),
 @An_OrderSeq_NUMB NUMERIC(2, 0),
 @Ac_Exists_INDC   CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OBLE_RETRIEVE_S17
  *     DESCRIPTION       : Returns 'Y' if the record exists for the given Case Id, order sequence number created for a support order of a case where Current datetime is between the effective start date for the obligation and effective end date for the obligation and enddate validity is highdate.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 24-SEP-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
 DECLARE  @Lc_No_INDC             CHAR(1) = 'N',
 		  @Lc_Yes_INDC            CHAR(1) = 'Y',
          @Ld_High_DATE           DATE 	  = '12/31/9999',
          @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();  
  
 SET @Ac_Exists_INDC = @Lc_No_INDC;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
    FROM OBLE_Y1 O
   WHERE O.Case_IDNO = @An_Case_IDNO
     AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB
     AND CONVERT(DATE, @Ld_Systemdatetime_DTTM) BETWEEN O.BeginObligation_DATE AND O.EndObligation_DATE
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; --End of OBLE_RETRIEVE_S17

GO
