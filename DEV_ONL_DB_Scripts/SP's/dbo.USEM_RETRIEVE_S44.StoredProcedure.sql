/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S44] (
 @An_Office_IDNO NUMERIC(3)
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S44
  *     DESCRIPTION       : Retrieve Worker ID in the office
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10/25/2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1.0
  */
 BEGIN
  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Ld_Current_DATE DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
  SELECT a.Worker_ID
    FROM UASM_Y1 a
   WHERE a.Office_IDNO = @An_Office_IDNO
    AND  a.Expire_DATE >= @Ld_Current_DATE
     AND a.EndValidity_DATE = @Ld_High_DATE
   ORDER BY Worker_ID;
 END


GO
