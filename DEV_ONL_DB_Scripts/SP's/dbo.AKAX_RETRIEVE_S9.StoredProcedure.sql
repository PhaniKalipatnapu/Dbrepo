/****** Object:  StoredProcedure [dbo].[AKAX_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AKAX_RETRIEVE_S9] (
 @An_MemberMci_IDNO   NUMERIC(10, 0),
 @Ac_TypeAlias_CODE   CHAR(1),
 @Ac_LastAlias_NAME   CHAR(20),
 @Ac_FirstAlias_NAME  CHAR(16),
 @Ac_MiddleAlias_NAME CHAR(20),
 @Ac_TitleAlias_NAME  CHAR(8),
 @Ac_SuffixAlias_NAME CHAR(4),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AKAX_RETRIEVE_S9
  *     DESCRIPTION       : Retrieve the count of records from Member Alias Names table for Unique Number Assigned by the System to the Member, First/Last/Middle/Suffix/Title name of the Member Alias and Type of Name
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999',
          @Lc_Space_TEXT CHAR(1) =' ';

  SELECT @Ai_Count_QNTY = COUNT (1)
    FROM AKAX_Y1 A
   WHERE A.MemberMci_IDNO = @An_MemberMci_IDNO
     AND A.LastAlias_NAME = @Ac_LastAlias_NAME
     AND A.FirstAlias_NAME = @Ac_FirstAlias_NAME
     AND A.MiddleAlias_NAME = ISNULL(@Ac_MiddleAlias_NAME, @Lc_Space_TEXT)
     AND A.TitleAlias_NAME = ISNULL(@Ac_TitleAlias_NAME, @Lc_Space_TEXT)
     AND A.SuffixAlias_NAME = ISNULL(@Ac_SuffixAlias_NAME, @Lc_Space_TEXT)
     AND A.TypeAlias_CODE = @Ac_TypeAlias_CODE
     AND A.EndValidity_DATE = @Ld_High_DATE;
 END; --END of AKAX_RETRIEVE_S9


GO
