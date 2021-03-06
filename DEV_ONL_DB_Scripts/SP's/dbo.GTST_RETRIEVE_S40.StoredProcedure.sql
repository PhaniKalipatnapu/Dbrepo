/****** Object:  StoredProcedure [dbo].[GTST_RETRIEVE_S40]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GTST_RETRIEVE_S40]
(
     @An_Case_IDNO                            NUMERIC(6) ,
     @An_MemberMci_IDNO                       NUMERIC(10),
     @An_Schedule_NUMB                        NUMERIC(10) ,
     @Ad_Test_DATE                            DATE   OUTPUT,
     @Ac_TypeTest_CODE                        CHAR(1) OUTPUT
 )
AS

/*
*      PROCEDURE NAME    : GTST_RETRIEVE_S40
 *     DESCRIPTION       : This sp will retrieve Member mci and schedule number  of NCP record
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      DECLARE
         @Lc_TestReslutCancel_CODE           CHAR(1) = 'C',
         @Lc_TestReslutFailedToAppear_CODE   CHAR(1) = 'F',
         @Ld_High_DATE                       DATE    = '12/31/9999';
         
       SELECT	@Ad_Test_DATE     = Test_Date,
				@Ac_TypeTest_CODE = TypeTest_CODE 
					FROM GTST_Y1 g
					WHERE g.Case_IDNO    = @An_Case_IDNO
					AND g.MemberMci_IDNO =@An_MemberMci_IDNO
					AND g.Schedule_NUMB = @An_Schedule_NUMB
					AND g.EndValidity_DATE=@Ld_High_DATE
					AND g.TestResult_CODE NOT IN (@Lc_TestReslutCancel_CODE,@Lc_TestReslutFailedToAppear_CODE)
					AND g.Test_DATE=(SELECT MAX(Test_DATE) 
											FROM GTST_Y1 s
											WHERE s.Case_IDNO   =@An_Case_IDNO 
											AND s.schedule_NUMB =@An_Schedule_NUMB
											AND s.MemberMci_IDNO=g.MemberMci_IDNO
											AND s.EndValidity_DATE = @Ld_High_DATE
											AND s.TestResult_CODE NOT IN (@Lc_TestReslutCancel_CODE,@Lc_TestReslutFailedToAppear_CODE));
								
END  -- END of GTST_RETRIEVE_S40


GO
