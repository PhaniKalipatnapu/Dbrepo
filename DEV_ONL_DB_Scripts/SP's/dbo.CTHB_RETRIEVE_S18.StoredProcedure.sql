/****** Object:  StoredProcedure [dbo].[CTHB_RETRIEVE_S18]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CTHB_RETRIEVE_S18] (
 @Ad_TransactionFrom_DATE   DATE,
 @Ad_TransactionTo_DATE     DATE,
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ac_FullDisplay_NAME       CHAR(37),
 @Ai_Count_QNTY             INT OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : CTHB_RETRIEVE_S18    
  *     DESCRIPTION       : To Show Total LO1 Requests Matched in CSENet Quick Locate (LO1) Statistical Report For a Given
                            Date Range,Name and IVDOutOfStateFips Code.  
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_FunctionQuickLocate_CODE CHAR(3) = 'LO1',
          @Lc_ActionP_CODE             CHAR(1) = 'P',
          @Lc_Space_TEXT               CHAR(1) = ' ',
          @Lc_ReasonLicad_CODE         CHAR(5) = 'LICAD',
          @Lc_ReasonLicem_CODE         CHAR(5) = 'LICEM',
          @Lc_ReasonLsadr_CODE         CHAR(5) = 'LSADR',
          @Lc_ReasonLsall_CODE         CHAR(5) = 'LSALL',
          @Lc_ReasonLsemp_CODE         CHAR(5) = 'LSEMP',
          @Lc_ReasonLsoth_CODE         CHAR(5) = 'LSOTH',
          @Lc_ReasonLsout_CODE         CHAR(5) = 'LSOUT';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM CTHB_Y1 a
         JOIN CFAR_Y1 b
          ON a.Action_CODE = b.Action_CODE
             AND a.Function_CODE = b.Function_CODE
             AND a.Reason_CODE = b.Reason_CODE
         JOIN CNCB_Y1 c
          ON c.TransHeader_IDNO = a.TransHeader_IDNO
   WHERE (@Ad_TransactionFrom_DATE IS NULL
           OR (@Ad_TransactionFrom_DATE IS NOT NULL
               AND a.Transaction_DATE >= @Ad_TransactionFrom_DATE))
     AND (@Ad_TransactionTo_DATE IS NULL
           OR (@Ad_TransactionTo_DATE IS NOT NULL
               AND a.Transaction_DATE <= @Ad_TransactionTo_DATE))
     AND (@Ac_FullDisplay_NAME IS NULL
           OR (@Ac_FullDisplay_NAME IS NOT NULL
               AND ((RTRIM (c.First_NAME) + @Lc_Space_TEXT + RTRIM (c.Last_NAME) = @Ac_FullDisplay_NAME)
                     OR ((RTRIM (c.First_NAME) = @Ac_FullDisplay_NAME)
                          OR (RTRIM (c.Last_NAME) = @Ac_FullDisplay_NAME)))))
     AND (@Ac_IVDOutOfStateFips_CODE IS NULL
           OR (@Ac_IVDOutOfStateFips_CODE IS NOT NULL
               AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE))
     AND a.Function_CODE = @Lc_FunctionQuickLocate_CODE
     AND a.Action_CODE = @Lc_ActionP_CODE
     AND a.Reason_CODE IN (@Lc_ReasonLsall_CODE, @Lc_ReasonLicad_CODE, @Lc_ReasonLicem_CODE, @Lc_ReasonLsadr_CODE,
                           @Lc_ReasonLsemp_CODE, @Lc_ReasonLsoth_CODE, @Lc_ReasonLsout_CODE);

 END; --End of CTHB_RETRIEVE_S18             

GO
