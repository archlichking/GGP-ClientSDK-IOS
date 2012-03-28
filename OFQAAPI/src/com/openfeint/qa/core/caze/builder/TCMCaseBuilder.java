
package com.openfeint.qa.core.caze.builder;

import android.content.Context;
import android.util.Log;

import com.openfeint.qa.core.caze.TestCase;
import com.openfeint.qa.core.caze.step.Step;
import com.openfeint.qa.core.exception.NoSuchStepException;
import com.openfeint.qa.core.exception.TCMIsnotReachableException;
import com.openfeint.qa.core.net.TCMCommunicator;
import com.openfeint.qa.core.util.StringUtil;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.util.ArrayList;

public class TCMCaseBuilder extends CaseBuilder {
    private TCMCommunicator tcm;

    @Override
    public TestCase[] buildCases(String suite_id) throws TCMIsnotReachableException {
        ArrayList<TestCase> tcs = new ArrayList<TestCase>();
        BufferedReader br;
        try {
            br = tcm.getTCMResponse(suite_id);
            // always give up first read line in tcm
            br.readLine();
            JSONObject json = new JSONObject(br.readLine());
            JSONArray arr = json.getJSONArray("cases");

            for (int i = 0; i < arr.length(); i++) {
                JSONObject o = (JSONObject) arr.get(i);
                String[] raw_case = StringUtil.splitSteps(o.getString("custom_steps"),
                        StringUtil.TCM_LINE_SPLIT);
                String[] raw_steps = StringUtil.extractSteps(raw_case);

                // pase case steps
                ArrayList<Step> steps = new ArrayList<Step>();
                for (String step : raw_steps) {
                    try {
                        steps.add(this.parser.parse(step));
                    } catch (NoSuchStepException nsse) {
                        Log.e(StringUtil.DEBUG_TAG, nsse.getMessage());
                    }
                }

                tcs.add(new TestCase(o.getString("id"), o.getString("title"), steps
                        .toArray(new Step[steps.size()])));
            }

            return tcs.toArray(new TestCase[tcs.size()]);
        } catch (Exception e) {
            Log.e(StringUtil.DEBUG_TAG, e.getMessage());
            throw new TCMIsnotReachableException("TCM is not reachable, please try again");
        }
    }

    @Override
    public TestCase buildCase(String suite_id, String id) throws TCMIsnotReachableException {
        try {
            TestCase[] tcs = this.buildCases(suite_id);
            TestCase t = null;
            for (TestCase tc : tcs) {
                if (tc.getId().equals(id)) {
                    t = tc;
                    break;
                }
            }

            return t;
        } catch (Exception e) {
            Log.e(StringUtil.DEBUG_TAG, e.getMessage());
            throw new TCMIsnotReachableException("TCM is not reachable, please try again");
        }
    }

    public TCMCaseBuilder(String type_raw, String packageName, Context context) {
        super(packageName, context);
        tcm = new TCMCommunicator(type_raw, packageName);
    }

}
