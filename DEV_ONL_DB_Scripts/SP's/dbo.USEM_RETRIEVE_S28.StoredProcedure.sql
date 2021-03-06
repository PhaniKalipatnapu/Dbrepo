/****** Object:  StoredProcedure [dbo].[USEM_RETRIEVE_S28]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USEM_RETRIEVE_S28] (
 @Ac_Worker_ID   CHAR(30),
 @An_Office_IDNO NUMERIC(3, 0),
 @Ac_First_NAME  CHAR(16) OUTPUT,
 @Ac_Middle_NAME CHAR(20) OUTPUT,
 @Ac_Last_NAME   CHAR(20) OUTPUT,
 @Ac_Suffix_NAME CHAR(4) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : USEM_RETRIEVE_S28
  *     DESCRIPTION       : Retrieve the worker name details for given office number        
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 11-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SELECT @Ac_Last_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL;

  DECLARE @Ld_High_DATE       DATE = '12/31/9999',
          @Ld_Systemdate_DTTM DATETIME2(0) = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT TOP 1 @Ac_Last_NAME = b.Last_NAME,
               @Ac_Suffix_NAME = b.Suffix_NAME,
               @Ac_First_NAME = b.First_NAME,
               @Ac_Middle_NAME = b.Middle_NAME
    FROM USRL_Y1 a
         JOIN USEM_Y1 b
          ON a.Worker_ID = b.Worker_ID
   WHERE a.Office_IDNO = ISNULL(@An_Office_IDNO,a.Office_IDNO)
     AND b.Worker_ID = @Ac_Worker_ID
     AND a.EndValidity_DATE = @Ld_High_DATE
     AND b.EndEmployment_DATE >= @Ld_Systemdate_DTTM
     AND b.BeginEmployment_DATE <= @Ld_Systemdate_DTTM
     AND b.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF USEM_RETRIEVE_S28


GO
