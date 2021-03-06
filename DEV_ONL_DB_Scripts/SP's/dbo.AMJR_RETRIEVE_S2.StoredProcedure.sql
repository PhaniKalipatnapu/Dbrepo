/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S2] (
 @Ac_ActivityMajor_CODE       CHAR(4),
 @Ac_Subsystem_CODE           CHAR(2),
 @An_TransactionEventSeq_NUMB NUMERIC(19, 0),
 @Ac_Exists_INDC              CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S2
  *     DESCRIPTION       : Returns 1 if a valid record exist(s) for the given Major Activity Code and Subsystem Code      
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  DECLARE @Ld_High_DATE DATE	= '12/31/9999',
  		  @Lc_No_TEXT	CHAR(1)	= 'N',
		  @Lc_Yes_TEXT	CHAR(1)	= 'Y';
		  
  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM AMJR_Y1 A
   WHERE A.Subsystem_CODE = @Ac_Subsystem_CODE
     AND A.ActivityMajor_CODE = @Ac_ActivityMajor_CODE
     AND A.TransactionEventSeq_NUMB = @An_TransactionEventSeq_NUMB
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of AMJR_RETRIEVE_S2

GO
