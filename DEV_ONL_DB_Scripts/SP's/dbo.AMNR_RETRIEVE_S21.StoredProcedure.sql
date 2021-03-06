/****** Object:  StoredProcedure [dbo].[AMNR_RETRIEVE_S21]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMNR_RETRIEVE_S21] (
 @Ac_ActivityMinor_CODE  CHAR(5),
 @An_OtherParty_IDNO     NUMERIC(9, 0),
 @Ac_Exists_INDC         CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : AMNR_RETRIEVE_S21
  *     DESCRIPTION       : Check if a record exists for Other Party number and Other Party Type Code.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 23-AUG-2011  
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
 
  DECLARE @Lc_Yes_TEXT           CHAR(1) = 'Y',
          @Lc_No_TEXT             CHAR(1) ='N',
          @Ld_High_DATE          DATE = '12/31/9999',
          @Lc_SchLocTypeLab_CODE CHAR(1) = 'L',
          @Lc_AddrState_TEXT     CHAR(2) = 'NJ';
          
     SET @Ac_Exists_INDC = @Lc_No_TEXT;
          
  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM OTHP_Y1 O
         JOIN AMNR_Y1 B
          ON O.TypeOthp_CODE = B.TypeLocation1_CODE
   WHERE O.OtherParty_IDNO = @An_OtherParty_IDNO
     AND ((O.State_ADDR = @Lc_AddrState_TEXT
           AND O.TypeOthp_CODE = @Lc_SchLocTypeLab_CODE)
           OR O.TypeOthp_CODE != @Lc_SchLocTypeLab_CODE)
     AND B.ActivityMinor_CODE = @Ac_ActivityMinor_CODE
     AND B.EndValidity_DATE = @Ld_High_DATE
     AND O.EndValidity_DATE = @Ld_High_DATE;
 END; -- END OF AMNR_RETRIEVE_S21 


GO
