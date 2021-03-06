/****** Object:  StoredProcedure [dbo].[AMJR_RETRIEVE_S19]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AMJR_RETRIEVE_S19] (
 @Ac_Subsystem_CODE CHAR(2)
 )
AS
 /*
  *     PROCEDURE NAME    : AMJR_RETRIEVE_S19
  *     DESCRIPTION       : Retrieve Major Activity code, Major Activity Description for a Subsystem of the Child Support system and Stop indicator.
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_INDC        CHAR(1) = 'N',
          @Lc_Percentage_PCT CHAR(1) = '%',
          @Ld_High_DATE      DATE = '12/31/9999';

  SELECT DISTINCT a.ActivityMajor_CODE,
         a.DescriptionActivity_TEXT
    FROM AMJR_Y1 a
   WHERE a.EndValidity_DATE = @Ld_High_DATE
     AND a.Subsystem_CODE LIKE ISNULL(LTRIM(RTRIM(@Ac_Subsystem_CODE)),@Lc_Percentage_PCT)
     AND a.Stop_INDC = @Lc_No_INDC
   ORDER BY ActivityMajor_CODE;
 END; -- End of AMJR_RETRIEVE_S19


GO
