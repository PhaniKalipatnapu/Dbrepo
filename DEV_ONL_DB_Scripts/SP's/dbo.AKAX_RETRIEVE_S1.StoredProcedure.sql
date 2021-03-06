/****** Object:  StoredProcedure [dbo].[AKAX_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AKAX_RETRIEVE_S1] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ac_TypeAlias_CODE CHAR(1),
 @Ac_Exists_INDC    CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AKAX_RETRIEVE_S1
  *     DESCRIPTION       : Retrieve the Last name of the Member Alias from Member Alias Names table for Unique Number Assigned by the System to the Member and the Type of Name equal to MAIDEN (M).
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_TEXT   CHAR(1) = 'N',
          @Lc_Yes_TEXT  CHAR(1) = 'Y',
          @Ld_High_DATE DATE = '12/31/9999';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM AKAX_Y1 a
   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND a.TypeAlias_CODE = @Ac_TypeAlias_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End of AKAX_RETRIEVE_S1


GO
