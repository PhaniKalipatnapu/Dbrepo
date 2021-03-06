/****** Object:  StoredProcedure [dbo].[MDET_RETRIEVE_S12]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MDET_RETRIEVE_S12] (
 @An_MemberMci_IDNO			NUMERIC(10, 0),
 @Ad_Incarceration_DATE     DATE OUTPUT,
 @Ad_Release_DATE		    DATE OUTPUT,
 @Ad_Deceased_DATE			DATE OUTPUT,
 @Ac_Incarceration_INDC		CHAR(1) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : MDET_RETRIEVE_S12    
  *     DESCRIPTION       : Retrieving Member Details.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 12-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SELECT @Ad_Incarceration_DATE = NULL,
         @Ad_Release_DATE = NULL,
         @Ad_Deceased_DATE = NULL,
         @Ac_Incarceration_INDC = NULL;

  DECLARE @Lc_Yes_INDC				CHAR(1) = 'Y',
		  @Lc_No_INDC				CHAR(1) = 'N',
		  @Lc_TypeInst1_CODE		CHAR(1) = '1',
		  @Lc_TypeInst2_CODE		CHAR(1) = '2',
		  @Lc_TypeInst4_CODE		CHAR(1) = '4',
		  @Lc_TypeInst6_CODE		CHAR(1) = '6',
		  @Lc_TypeInst12_CODE		CHAR(2) = '12',
          @Ld_High_DATE				DATE = '12/31/9999',
          @Ld_Low_DATE				DATE = '01/01/0001';

  SELECT @Ad_Incarceration_DATE = M.Incarceration_DATE,
		@Ac_Incarceration_INDC = @Lc_Yes_INDC,
		@Ad_Deceased_DATE = D.Deceased_DATE,
		@Ad_Release_DATE = CASE
			WHEN M.Release_DATE NOT IN (@Ld_High_DATE,@Ld_Low_DATE)
			THEN M.Release_DATE
			ELSE @Ld_High_DATE
			END
    FROM MDET_Y1 M, DEMO_Y1 D
   WHERE M.MemberMci_IDNO = @An_MemberMci_IDNO
		AND M.MemberMci_IDNO = D.MemberMci_IDNO
		AND M.TypeInst_CODE IN (@Lc_TypeInst1_CODE, @Lc_TypeInst2_CODE, @Lc_TypeInst4_CODE, @Lc_TypeInst6_CODE, @Lc_TypeInst12_CODE)
		AND M.EndValidity_DATE = @Ld_High_DATE;
 END; -- End of MDET_RETRIEVE_S12

GO
